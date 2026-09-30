import '../entities/recipe_entity.dart';
import '../repositories/recipe_repository.dart';

class GetRecipeDetail {
  const GetRecipeDetail(this.repository);
  final RecipeRepository repository;
  Future<RecipeEntity> call(String id) => repository.getRecipeDetail(id);
}
