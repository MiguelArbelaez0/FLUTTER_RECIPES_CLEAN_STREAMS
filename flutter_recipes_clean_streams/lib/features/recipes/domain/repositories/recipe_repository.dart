import '../entities/recipe_entity.dart';
import '../entities/category_entity.dart';

abstract interface class RecipeRepository {
  Future<RecipeEntity> getRandomRecipe();
  Future<RecipeEntity> getRecipeDetail(String id);
  Future<List<RecipeEntity>> searchRecipes(String query);
  Future<List<CategoryEntity>> getCategories();
  Future<List<RecipeEntity>> getRecipesByCategory(String category);
}
