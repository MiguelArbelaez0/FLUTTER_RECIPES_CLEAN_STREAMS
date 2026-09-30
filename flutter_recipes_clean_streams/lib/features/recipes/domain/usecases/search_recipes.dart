import '../entities/recipe_entity.dart';
import '../repositories/recipe_repository.dart';

class SearchRecipes {
  const SearchRecipes(this.repository);
  final RecipeRepository repository;
  Future<List<RecipeEntity>> call(String query) =>
      repository.searchRecipes(query);
}
