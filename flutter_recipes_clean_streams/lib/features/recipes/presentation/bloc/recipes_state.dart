import 'package:equatable/equatable.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/recipe_entity.dart';

enum RecipesStatus { initial, loading, success, failure }

enum RecipeDetailStatus { initial, loading, success, failure }

enum CategoriesStatus { initial, loading, success, failure }

class RecipesState extends Equatable {
  const RecipesState({
    this.status = RecipesStatus.initial,
    this.searchStatus = RecipesStatus.initial,
    this.recipes = const [],
    this.searchResults = const [],
    this.detailStatus = RecipeDetailStatus.initial,
    this.selectedRecipe,
    this.errorMessage,
    this.searchErrorMessage,
    this.categoriesErrorMessage,
    this.categoriesStatus = CategoriesStatus.initial,
    this.categories = const [],
    this.categoryRecipes = const {},
    this.categoryLoading = const {},
    this.categoryErrors = const {},
  });
  final RecipesStatus status;
  final RecipesStatus searchStatus;
  final List<RecipeEntity> recipes, searchResults;
  final RecipeDetailStatus detailStatus;
  final RecipeEntity? selectedRecipe;
  final String? errorMessage;
  final String? searchErrorMessage, categoriesErrorMessage;
  final CategoriesStatus categoriesStatus;
  final List<CategoryEntity> categories;
  final Map<String, List<RecipeEntity>> categoryRecipes;
  final Set<String> categoryLoading;
  final Map<String, String> categoryErrors;
  RecipesState copyWith({
    RecipesStatus? status,
    RecipesStatus? searchStatus,
    List<RecipeEntity>? recipes,
    List<RecipeEntity>? searchResults,
    RecipeDetailStatus? detailStatus,
    RecipeEntity? selectedRecipe,
    String? errorMessage,
    String? searchErrorMessage,
    String? categoriesErrorMessage,
    bool clearSearchError = false,
    bool clearError = false,
    bool clearSelectedRecipe = false,
    CategoriesStatus? categoriesStatus,
    List<CategoryEntity>? categories,
    Map<String, List<RecipeEntity>>? categoryRecipes,
    Set<String>? categoryLoading,
    Map<String, String>? categoryErrors,
  }) => RecipesState(
    status: status ?? this.status,
    searchStatus: searchStatus ?? this.searchStatus,
    recipes: recipes ?? this.recipes,
    searchResults: searchResults ?? this.searchResults,
    detailStatus: detailStatus ?? this.detailStatus,
    selectedRecipe: clearSelectedRecipe
        ? null
        : selectedRecipe ?? this.selectedRecipe,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    searchErrorMessage: clearSearchError
        ? null
        : searchErrorMessage ?? this.searchErrorMessage,
    categoriesErrorMessage:
        categoriesErrorMessage ?? this.categoriesErrorMessage,
    categoriesStatus: categoriesStatus ?? this.categoriesStatus,
    categories: categories ?? this.categories,
    categoryRecipes: categoryRecipes ?? this.categoryRecipes,
    categoryLoading: categoryLoading ?? this.categoryLoading,
    categoryErrors: categoryErrors ?? this.categoryErrors,
  );
  @override
  List<Object?> get props => [
    status,
    searchStatus,
    recipes,
    searchResults,
    detailStatus,
    selectedRecipe,
    errorMessage,
    searchErrorMessage,
    categoriesErrorMessage,
    categoriesStatus,
    categories,
    categoryRecipes,
    categoryLoading,
    categoryErrors,
  ];
}
