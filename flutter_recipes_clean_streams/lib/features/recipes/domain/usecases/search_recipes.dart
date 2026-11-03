import 'package:flutter_recipes_clean_streams/core/utils/request_cancellation.dart';

import '../entities/recipe_entity.dart';
import '../repositories/recipe_repository.dart';

class SearchRecipes {
  const SearchRecipes(this.repository);
  final RecipeRepository repository;
  Future<List<RecipeEntity>> call(
    String query, {
    RequestCancellation? cancellation,
  }) => query.trim().length < 2
      ? Future.value(const [])
      : repository.searchRecipes(query.trim(), cancellation: cancellation);
}
