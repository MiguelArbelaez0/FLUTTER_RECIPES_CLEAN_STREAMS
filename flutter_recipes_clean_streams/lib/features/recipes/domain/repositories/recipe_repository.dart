import '../entities/recipe_entity.dart';

abstract interface class RecipeRepository {
  Future<RecipeEntity> getRandomRecipe();
  Future<RecipeEntity> getRecipeDetail(String id);
  Future<List<RecipeEntity>> searchRecipes(String query);
}
