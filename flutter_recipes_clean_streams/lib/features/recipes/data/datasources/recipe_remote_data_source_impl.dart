import 'package:dio/dio.dart';

import '../../../../core/error/exceptions/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/recipe_model.dart';
import 'recipe_remote_data_source.dart';

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  const RecipeRemoteDataSourceImpl(this.client);

  final ApiClient client;

  Future<T> _request<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (error) {
      if (error.response == null ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        throw NetworkException(error.message ?? 'Network request failed.');
      }
      throw ServerException(
        'TheMealDB returned HTTP ${error.response?.statusCode ?? 'error'}.',
      );
    } on FormatException catch (error) {
      throw ParsingException(error.message);
    } on TypeError catch (error) {
      throw ParsingException(error.toString());
    }
  }

  List<RecipeModel> _meals(Object? payload) {
    if (payload is! Map<String, dynamic> || !payload.containsKey('meals')) {
      throw const FormatException('Invalid meal response.');
    }
    final meals = payload['meals'];
    if (meals == null) return const [];
    if (meals is! List) throw const FormatException('Invalid meals list.');
    return meals
        .map(
          (meal) =>
              RecipeModel.fromJson(Map<String, dynamic>.from(meal as Map)),
        )
        .toList();
  }

  @override
  Future<RecipeModel> getRandomRecipe() => _request(() async {
    final response = await client.dio.get<Map<String, dynamic>>('/random.php');
    final meals = _meals(response.data);
    if (meals.isEmpty) {
      throw const RecipeNotFoundException('No random meal was returned.');
    }
    return meals.first;
  });

  @override
  Future<RecipeModel> getRecipeDetail(String id) => _request(() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/lookup.php',
      queryParameters: {'i': id},
    );
    final meals = _meals(response.data);
    if (meals.isEmpty) {
      throw const RecipeNotFoundException('Recipe not found.');
    }
    return meals.first;
  });

  @override
  Future<List<RecipeModel>> searchRecipes(String query) => _request(() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/search.php',
      queryParameters: {'s': query},
    );
    return _meals(response.data);
  });
}
