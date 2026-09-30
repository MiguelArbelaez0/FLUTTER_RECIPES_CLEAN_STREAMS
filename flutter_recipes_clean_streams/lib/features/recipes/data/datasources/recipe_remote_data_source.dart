import '../models/recipe_model.dart';

abstract interface class RecipeRemoteDataSource {
  Future<RecipeModel> getRandomRecipe();
  Future<RecipeModel> getRecipeDetail(String id);
  Future<List<RecipeModel>> searchRecipes(String query);
  Future<List<RecipeModel>> getRecipesByCategory(String category);
}
