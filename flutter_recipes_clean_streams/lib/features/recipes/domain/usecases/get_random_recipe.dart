import '../entities/recipe_entity.dart';
import '../repositories/recipe_repository.dart';

class GetRandomRecipe {
  const GetRandomRecipe(this.repository);

  final RecipeRepository repository;

  Future<RecipeEntity> call() => repository.getRandomRecipe();
}
