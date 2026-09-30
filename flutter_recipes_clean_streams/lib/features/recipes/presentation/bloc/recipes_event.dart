import 'package:equatable/equatable.dart';

abstract class RecipesEvent extends Equatable {
  const RecipesEvent();
  @override
  List<Object?> get props => [];
}

class LoadRandomRecipes extends RecipesEvent {
  const LoadRandomRecipes({this.refresh = false});
  final bool refresh;
  @override
  List<Object?> get props => [refresh];
}

class LoadHome extends RecipesEvent {
  const LoadHome();
}

class LoadCategories extends RecipesEvent {
  const LoadCategories();
}

class LoadRecipesByCategory extends RecipesEvent {
  const LoadRecipesByCategory(this.category);
  final String category;
  @override
  List<Object?> get props => [category];
}

class RetryHome extends RecipesEvent {
  const RetryHome();
}

class SearchRecipesRequested extends RecipesEvent {
  const SearchRecipesRequested(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class LoadRecipeDetail extends RecipesEvent {
  const LoadRecipeDetail(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
