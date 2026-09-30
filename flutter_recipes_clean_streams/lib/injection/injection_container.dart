import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../core/network/api_client.dart';
import '../features/recipes/data/datasources/recipe_remote_data_source.dart';
import '../features/recipes/data/datasources/recipe_remote_data_source_impl.dart';
import '../features/recipes/data/repositories/recipe_repository_impl.dart';
import '../features/recipes/domain/repositories/recipe_repository.dart';
import '../features/recipes/domain/usecases/get_random_recipe.dart';
import '../features/recipes/domain/usecases/get_recipe_detail.dart';
import '../features/recipes/domain/usecases/search_recipes.dart';
import '../features/recipes/presentation/bloc/recipes_bloc.dart';

final getIt = GetIt.instance;
void configureDependencies() {
  getIt.registerLazySingleton(() => ApiClient());
  getIt.registerLazySingleton<Dio>(() => getIt<ApiClient>().dio);
  getIt.registerLazySingleton<RecipeRemoteDataSource>(
    () => RecipeRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(getIt<RecipeRemoteDataSource>()),
  );
  getIt.registerLazySingleton(() => GetRandomRecipe(getIt<RecipeRepository>()));
  getIt.registerLazySingleton(() => GetRecipeDetail(getIt<RecipeRepository>()));
  getIt.registerLazySingleton(() => SearchRecipes(getIt<RecipeRepository>()));
  getIt.registerFactory(
    () => RecipesBloc(
      getRandomRecipe: getIt(),
      getRecipeDetail: getIt(),
      searchRecipes: getIt(),
    ),
  );
}
