import '../entities/recipe_entity.dart';
import '../repositories/recipe_repository.dart';

class GetRecipesByCategory {
  const GetRecipesByCategory(this.repository);
  final RecipeRepository repository;

  Future<List<RecipeEntity>> call(String category) =>
      repository.getRecipesByCategory(category);
}
