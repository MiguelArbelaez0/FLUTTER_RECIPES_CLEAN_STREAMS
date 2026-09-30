import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../core/error/failures/failure.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_random_recipe.dart';
import '../../domain/usecases/get_recipes_by_category.dart';
import '../../domain/usecases/get_recipe_detail.dart';
import '../../domain/usecases/search_recipes.dart';
import 'recipes_event.dart';
import 'recipes_state.dart';

EventTransformer<E> _debounce<E>(Duration duration) =>
    (events, mapper) => events.debounce(duration).switchMap(mapper);

class RecipesBloc extends Bloc<RecipesEvent, RecipesState> {
  static const _randomRecipeTarget = 6;
  static const _maxRandomRequests = 9;
  static const _randomRequestBatchSize = 3;

  RecipesBloc({
    required this.getRandomRecipe,
    required this.getRecipeDetail,
    required this.searchRecipes,
    required this.getCategories,
    required this.getRecipesByCategory,
  }) : super(const RecipesState()) {
    on<LoadHome>((event, emit) {
      add(const LoadCategories());
      add(const LoadRandomRecipes());
    });
    on<RetryHome>((event, emit) {
      add(const LoadCategories());
      add(const LoadRandomRecipes(refresh: true));
    });
    on<LoadCategories>(_loadCategories);
    on<LoadRecipesByCategory>(_loadByCategory);
    on<LoadRandomRecipes>(_loadRandom);
    on<LoadRecipeDetail>(_loadDetail);
    on<SearchRecipesRequested>(
      _search,
      transformer: _debounce(const Duration(milliseconds: 350)),
    );
  }
  final GetRandomRecipe getRandomRecipe;
  final GetRecipeDetail getRecipeDetail;
  final SearchRecipes searchRecipes;
  final GetCategories getCategories;
  final GetRecipesByCategory getRecipesByCategory;

  Future<void> _loadCategories(
    LoadCategories event,
    Emitter<RecipesState> emit,
  ) async {
    emit(state.copyWith(categoriesStatus: CategoriesStatus.loading));
    try {
      final categories = await getCategories();
      emit(
        state.copyWith(
          categoriesStatus: CategoriesStatus.success,
          categories: categories,
          categoryErrors: const {},
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          categoriesStatus: CategoriesStatus.failure,
          errorMessage: _message(error),
        ),
      );
    }
  }

  Future<void> _loadByCategory(
    LoadRecipesByCategory event,
    Emitter<RecipesState> emit,
  ) async {
    final category = event.category;
    if (state.categoryLoading.contains(category) ||
        state.categoryRecipes.containsKey(category)) {
      return;
    }
    emit(
      state.copyWith(
        categoryLoading: {...state.categoryLoading, category},
        categoryErrors: {...state.categoryErrors}..remove(category),
      ),
    );
    try {
      final recipes = await getRecipesByCategory(category);
      emit(
        state.copyWith(
          categoryRecipes: {...state.categoryRecipes, category: recipes},
          categoryLoading: {...state.categoryLoading}..remove(category),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          categoryLoading: {...state.categoryLoading}..remove(category),
          categoryErrors: {...state.categoryErrors, category: _message(error)},
        ),
      );
    }
  }

  Future<void> _loadRandom(
    LoadRandomRecipes event,
    Emitter<RecipesState> emit,
  ) async {
    if (state.status == RecipesStatus.loading) return;

    emit(state.copyWith(status: RecipesStatus.loading, clearError: true));

    final recipes = <RecipeEntity>[];
    final recipeIds = <String>{};
    var requestsMade = 0;

    while (recipes.length < _randomRecipeTarget &&
        requestsMade < _maxRandomRequests) {
      final remainingRequests = _maxRandomRequests - requestsMade;
      final batchSize = remainingRequests < _randomRequestBatchSize
          ? remainingRequests
          : _randomRequestBatchSize;
      final batch = await Future.wait(
        List.generate(batchSize, (_) => _loadRandomSafely()),
      );
      requestsMade += batchSize;

      for (final recipe in batch) {
        if (recipes.length >= _randomRecipeTarget) break;
        if (recipe != null && recipeIds.add(recipe.id)) recipes.add(recipe);
      }
    }

    if (recipes.isEmpty) {
      emit(
        state.copyWith(
          status: RecipesStatus.failure,
          errorMessage:
              'Could not load recipes. Check your connection and retry.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: RecipesStatus.success,
        recipes: recipes,
        clearError: true,
      ),
    );
  }

  Future<RecipeEntity?> _loadRandomSafely() async {
    try {
      return await getRandomRecipe();
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadDetail(
    LoadRecipeDetail event,
    Emitter<RecipesState> emit,
  ) async {
    emit(
      state.copyWith(
        detailStatus: RecipeDetailStatus.loading,
        clearSelectedRecipe: true,
        clearError: true,
      ),
    );
    try {
      emit(
        state.copyWith(
          detailStatus: RecipeDetailStatus.success,
          selectedRecipe: await getRecipeDetail(event.id),
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          detailStatus: RecipeDetailStatus.failure,
          errorMessage: _message(error),
        ),
      );
    }
  }

  Future<void> _search(
    SearchRecipesRequested event,
    Emitter<RecipesState> emit,
  ) async {
    final query = event.query.trim();
    if (query.length < 2) {
      emit(state.copyWith(searchResults: const [], clearError: true));
      return;
    }
    emit(state.copyWith(status: RecipesStatus.loading, clearError: true));
    try {
      emit(
        state.copyWith(
          status: RecipesStatus.success,
          searchResults: await searchRecipes(query),
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RecipesStatus.failure,
          errorMessage: _message(error),
        ),
      );
    }
  }

  String _message(Object error) =>
      error is Failure ? error.message : 'Ocurrió un error inesperado.';
}
