import '../entities/category_entity.dart';
import '../repositories/recipe_repository.dart';

class GetCategories {
  const GetCategories(this.repository);
  final RecipeRepository repository;

  Future<List<CategoryEntity>> call() => repository.getCategories();
}
