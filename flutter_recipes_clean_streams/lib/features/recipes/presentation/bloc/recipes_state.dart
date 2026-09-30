import 'package:equatable/equatable.dart';

import '../../domain/entities/recipe_entity.dart';

enum RecipesStatus { initial, loading, success, failure }

enum RecipeDetailStatus { initial, loading, success, failure }

class RecipesState extends Equatable {
  const RecipesState({
    this.status = RecipesStatus.initial,
    this.recipes = const [],
    this.searchResults = const [],
    this.detailStatus = RecipeDetailStatus.initial,
    this.selectedRecipe,
    this.errorMessage,
  });
  final RecipesStatus status;
  final List<RecipeEntity> recipes, searchResults;
  final RecipeDetailStatus detailStatus;
  final RecipeEntity? selectedRecipe;
  final String? errorMessage;
  RecipesState copyWith({
    RecipesStatus? status,
    List<RecipeEntity>? recipes,
    List<RecipeEntity>? searchResults,
    RecipeDetailStatus? detailStatus,
    RecipeEntity? selectedRecipe,
    String? errorMessage,
    bool clearError = false,
    bool clearSelectedRecipe = false,
  }) => RecipesState(
    status: status ?? this.status,
    recipes: recipes ?? this.recipes,
    searchResults: searchResults ?? this.searchResults,
    detailStatus: detailStatus ?? this.detailStatus,
    selectedRecipe: clearSelectedRecipe
        ? null
        : selectedRecipe ?? this.selectedRecipe,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
  @override
  List<Object?> get props => [
    status,
    recipes,
    searchResults,
    detailStatus,
    selectedRecipe,
    errorMessage,
  ];
}
