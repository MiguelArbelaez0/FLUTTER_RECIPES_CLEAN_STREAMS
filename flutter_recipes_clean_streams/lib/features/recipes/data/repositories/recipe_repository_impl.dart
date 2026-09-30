import '../../../../core/error/exceptions/exceptions.dart';
import '../../../../core/error/failures/failure.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_remote_data_source.dart';
import '../datasources/category_remote_data_source.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  const RecipeRepositoryImpl(this.remote, this.categoryRemote);
  final RecipeRemoteDataSource remote;
  final CategoryRemoteDataSource categoryRemote;
  @override
  Future<RecipeEntity> getRandomRecipe() =>
      _guard(() async => (await remote.getRandomRecipe()).toEntity());
  @override
  Future<RecipeEntity> getRecipeDetail(String id) async =>
      _guard(() async => (await remote.getRecipeDetail(id)).toEntity());
  @override
  Future<List<RecipeEntity>> searchRecipes(String query) async => _guard(
    () async =>
        (await remote.searchRecipes(query))
            .map((recipe) => recipe.toEntity())
            .toList(),
  );

  @override
  Future<List<CategoryEntity>> getCategories() async => _guard(
    () async => (await categoryRemote.getCategories())
        .map((category) => category.toEntity())
        .toList(),
  );

  @override
  Future<List<RecipeEntity>> getRecipesByCategory(String category) async =>
      _guard(
        () async =>
            (await remote.getRecipesByCategory(category))
                .map((recipe) => recipe.toEntity())
                .toList(),
      );

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on RecipeNotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on ParsingException catch (e) {
      throw ParsingFailure(e.message);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }
}
