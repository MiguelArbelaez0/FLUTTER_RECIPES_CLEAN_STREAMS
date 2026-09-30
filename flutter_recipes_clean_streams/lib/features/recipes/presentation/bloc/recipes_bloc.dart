import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../core/error/failures/failure.dart';
import '../../domain/usecases/get_random_recipe.dart';
import '../../domain/usecases/get_recipe_detail.dart';
import '../../domain/usecases/search_recipes.dart';
import 'recipes_event.dart';
import 'recipes_state.dart';

EventTransformer<E> _debounce<E>(Duration duration) =>
    (events, mapper) => events.debounce(duration).switchMap(mapper);

class RecipesBloc extends Bloc<RecipesEvent, RecipesState> {
  RecipesBloc({
    required this.getRandomRecipe,
    required this.getRecipeDetail,
    required this.searchRecipes,
  }) : super(const RecipesState()) {
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

  Future<void> _loadRandom(
    LoadRandomRecipes event,
    Emitter<RecipesState> emit,
  ) async {
    emit(state.copyWith(status: RecipesStatus.loading, clearError: true));
    try {
      emit(
        state.copyWith(
          status: RecipesStatus.success,
          recipes: [await getRandomRecipe()],
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
