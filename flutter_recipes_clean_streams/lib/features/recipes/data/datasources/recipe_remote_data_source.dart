import 'package:flutter_recipes_clean_streams/core/utils/request_cancellation.dart';

import '../models/recipe_model.dart';

abstract interface class RecipeRemoteDataSource {
  Future<RecipeModel> getRandomRecipe();
  Future<RecipeModel> getRecipeDetail(String id);
  Future<List<RecipeModel>> searchRecipes(
    String query, {
    RequestCancellation? cancellation,
  });
  Future<List<RecipeModel>> getRecipesByCategory(String category);
}
