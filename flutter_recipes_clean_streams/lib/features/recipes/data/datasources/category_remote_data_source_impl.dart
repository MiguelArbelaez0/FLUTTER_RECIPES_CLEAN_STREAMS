import 'package:dio/dio.dart';

import '../../../../core/error/exceptions/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';
import 'category_remote_data_source.dart';

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  const CategoryRemoteDataSourceImpl(this.client);
  final ApiClient client;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        '/categories.php',
      );
      final payload = response.data;
      if (payload == null || !payload.containsKey('categories')) {
        throw const ParsingException('Invalid category response.');
      }
      final categories = payload['categories'];
      if (categories is! List) {
        throw const ParsingException('Invalid categories list.');
      }
      return categories
          .map(
            (item) =>
                CategoryModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .where((category) => category.name.isNotEmpty)
          .toList();
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
    } on TypeError catch (error) {
      throw ParsingException(error.toString());
    } on FormatException catch (error) {
      throw ParsingException(error.message);
    }
  }
}
