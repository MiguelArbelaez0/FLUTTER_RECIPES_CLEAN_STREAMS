import 'package:flutter_recipes_clean_streams/core/utils/request_cancellation.dart';

import '../entities/category_entity.dart';
import '../entities/recipe_entity.dart';

abstract interface class RecipeRepository {
  Future<RecipeEntity> getRandomRecipe();
  Future<RecipeEntity> getRecipeDetail(String id);
  Future<List<RecipeEntity>> searchRecipes(
    String query, {
    RequestCancellation? cancellation,
  });
  Future<List<CategoryEntity>> getCategories();
  Future<List<RecipeEntity>> getRecipesByCategory(String category);
}
