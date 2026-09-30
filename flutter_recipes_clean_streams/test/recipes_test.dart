import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipes_clean_streams/core/error/exceptions/exceptions.dart';
import 'package:flutter_recipes_clean_streams/core/error/failures/failure.dart';
import 'package:flutter_recipes_clean_streams/core/network/api_client.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/data/datasources/recipe_remote_data_source.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/data/datasources/recipe_remote_data_source_impl.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/data/datasources/category_remote_data_source.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/data/datasources/category_remote_data_source_impl.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/data/models/recipe_model.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/data/models/category_model.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/data/repositories/recipe_repository_impl.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/entities/recipe_entity.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/entities/category_entity.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/usecases/get_random_recipe.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/usecases/get_recipe_detail.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/usecases/get_categories.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/usecases/get_recipes_by_category.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/usecases/search_recipes.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/presentation/bloc/recipes_bloc.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/presentation/bloc/recipes_event.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/presentation/bloc/recipes_state.dart';

const _meal = <String, dynamic>{
  'idMeal': '52795',
  'strMeal': 'Chicken Handi',
  'strCategory': 'Chicken',
  'strArea': 'Indian',
  'strInstructions': 'Cook the chicken.',
  'strMealThumb': 'https://www.themealdb.com/images/example.jpg',
  'strIngredient1': 'Chicken',
  'strMeasure1': '1 kg',
  'strIngredient2': '',
  'strMeasure2': '',
};

class _FakeRemote implements RecipeRemoteDataSource {
  final recipe = RecipeModel.fromJson(_meal);
  bool emptySearch = false;

  @override
  Future<RecipeModel> getRandomRecipe() async => recipe;

  @override
  Future<RecipeModel> getRecipeDetail(String id) async => recipe;

  @override
  Future<List<RecipeModel>> searchRecipes(String query) async =>
      emptySearch ? [] : [recipe];

  @override
  Future<List<RecipeModel>> getRecipesByCategory(String category) async => [
    recipe,
  ];
}

class _FakeRepository implements RecipeRepository {
  final recipe = RecipeModel.fromJson(_meal).toEntity();
  bool emptySearch = false;

  @override
  Future<RecipeEntity> getRandomRecipe() async => recipe;

  @override
  Future<RecipeEntity> getRecipeDetail(String id) async => recipe;

  @override
  Future<List<RecipeEntity>> searchRecipes(String query) async =>
      emptySearch ? [] : [recipe];

  @override
  Future<List<CategoryEntity>> getCategories() async => const [
    CategoryEntity(
      id: '1',
      name: 'Chicken',
      imageUrl: 'https://example.com/chicken.jpg',
    ),
  ];

  @override
  Future<List<RecipeEntity>> getRecipesByCategory(String category) async => [
    recipe,
  ];
}

class _MultiRandomRepository extends _FakeRepository {
  int randomCalls = 0;

  @override
  Future<RecipeEntity> getRandomRecipe() async {
    final request = randomCalls++;
    if (request == 1) throw StateError('one random request failed');
    return RecipeEntity(id: '$request', name: 'Meal $request');
  }
}

class _StaticAdapter implements HttpClientAdapter {
  _StaticAdapter(this.body, {this.statusCode = 200, this.failNetwork = false});

  final Object body;
  final int statusCode;
  final bool failNetwork;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (failNetwork) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        message: 'offline',
      );
    }
    return ResponseBody(
      Stream.value(Uint8List.fromList(utf8.encode(jsonEncode(body)))),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

RecipeRemoteDataSourceImpl _dataSource(_StaticAdapter adapter) {
  final dio = Dio(
    BaseOptions(baseUrl: 'https://www.themealdb.com/api/json/v1/1'),
  )..httpClientAdapter = adapter;
  return RecipeRemoteDataSourceImpl(ApiClient(dio: dio));
}

CategoryRemoteDataSourceImpl _categoryDataSource(_StaticAdapter adapter) {
  final dio = Dio(
    BaseOptions(baseUrl: 'https://www.themealdb.com/api/json/v1/1'),
  )..httpClientAdapter = adapter;
  return CategoryRemoteDataSourceImpl(ApiClient(dio: dio));
}

class _FakeCategoryRemote implements CategoryRemoteDataSource {
  @override
  Future<List<CategoryModel>> getCategories() async => const [
    CategoryModel(
      id: '1',
      name: 'Chicken',
      imageUrl: 'https://example.com/chicken.jpg',
    ),
  ];
}

void main() {
  test('RecipeModel converts TheMealDB fields to clean entities', () {
    final model = RecipeModel.fromJson(_meal);
    final entity = model.toEntity();

    expect(entity.id, '52795');
    expect(entity.name, 'Chicken Handi');
    expect(entity.category, 'Chicken');
    expect(entity.area, 'Indian');
    expect(entity.imageUrl, contains('themealdb.com'));
    expect(entity.ingredients, [
      const IngredientEntity(name: 'Chicken', measure: '1 kg'),
    ]);
    expect(RecipeModel.fromJson(model.toJson()).toEntity(), entity);
  });

  test('search calls search.php with s and returns meals', () async {
    final adapter = _StaticAdapter({
      'meals': [_meal],
    });
    final results = await _dataSource(adapter).searchRecipes('Chicken');

    expect(results.single.toEntity().name, 'Chicken Handi');
    expect(adapter.lastRequest?.path, '/search.php');
    expect(adapter.lastRequest?.queryParameters['s'], 'Chicken');
  });

  test('search with no meals returns an empty list', () async {
    final results = await _dataSource(_StaticAdapter({'meals': null}))
        .searchRecipes('No matching dish');

    expect(results, isEmpty);
  });

  test('random and detail use TheMealDB endpoints', () async {
    final randomAdapter = _StaticAdapter({
      'meals': [_meal],
    });
    final random = await _dataSource(randomAdapter).getRandomRecipe();
    expect(randomAdapter.lastRequest?.path, '/random.php');
    expect(random.name, 'Chicken Handi');

    final detailAdapter = _StaticAdapter({
      'meals': [_meal],
    });
    final detail = await _dataSource(detailAdapter).getRecipeDetail('52795');
    expect(detailAdapter.lastRequest?.path, '/lookup.php');
    expect(detailAdapter.lastRequest?.queryParameters['i'], '52795');
    expect(detail.name, 'Chicken Handi');
  });

  test('categories and category filter use TheMealDB endpoints', () async {
    final categoriesAdapter = _StaticAdapter({
      'categories': [
        {
          'idCategory': '1',
          'strCategory': 'Chicken',
          'strCategoryDescription': 'Chicken dishes',
          'strCategoryThumb': 'https://www.themealdb.com/chicken.jpg',
        },
      ],
    });
    final categories = await _categoryDataSource(categoriesAdapter)
        .getCategories();
    expect(categories.single.toEntity().name, 'Chicken');
    expect(categories.single.toEntity().imageUrl, contains('themealdb.com'));
    expect(categoriesAdapter.lastRequest?.path, '/categories.php');

    final filterAdapter = _StaticAdapter({
      'meals': [
        {
          'idMeal': '52795',
          'strMeal': 'Chicken Handi',
          'strMealThumb': 'https://example.com/meal.jpg',
        },
      ],
    });
    final recipes = await _dataSource(filterAdapter)
        .getRecipesByCategory('Chicken');
    expect(recipes.single.name, 'Chicken Handi');
    expect(filterAdapter.lastRequest?.path, '/filter.php');
    expect(filterAdapter.lastRequest?.queryParameters['c'], 'Chicken');
  });

  test(
    'datasource maps transport, HTTP, malformed and missing-meal errors',
    () async {
      expect(
        _dataSource(_StaticAdapter({}, failNetwork: true)).searchRecipes('x'),
        throwsA(isA<NetworkException>()),
      );
      expect(
        _dataSource(_StaticAdapter({}, statusCode: 500)).searchRecipes('x'),
        throwsA(isA<ServerException>()),
      );
      expect(
        _dataSource(_StaticAdapter({'unexpected': []})).searchRecipes('x'),
        throwsA(isA<ParsingException>()),
      );
      expect(
        _dataSource(_StaticAdapter({'meals': null})).getRecipeDetail('0'),
        throwsA(isA<RecipeNotFoundException>()),
      );
    },
  );

  test('repository translates datasource failures and entities', () async {
    final repository = RecipeRepositoryImpl(
      _FakeRemote(),
      _FakeCategoryRemote(),
    );
    expect((await repository.getRandomRecipe()).name, 'Chicken Handi');

    final failing = RecipeRepositoryImpl(
      _FailingRemote(),
      _FailingCategoryRemote(),
    );
    expect(failing.getRandomRecipe(), throwsA(isA<NetworkFailure>()));
  });

  test('use cases delegate through the repository contract', () async {
    final repository = _FakeRepository();
    expect((await GetRandomRecipe(repository)()).id, '52795');
    expect((await GetRecipeDetail(repository)('52795')).name, 'Chicken Handi');
    expect(
      (await SearchRecipes(repository)('Chicken')).single.name,
      'Chicken Handi',
    );
    expect((await GetCategories(repository)()).single.name, 'Chicken');
    expect(
      (await GetRecipesByCategory(repository)('Chicken')).single.name,
      'Chicken Handi',
    );
  });

  test('BLoC emits random, search, no-results and detail states', () async {
    final repository = _FakeRepository();
    final bloc = RecipesBloc(
      getRandomRecipe: GetRandomRecipe(repository),
      getRecipeDetail: GetRecipeDetail(repository),
      searchRecipes: SearchRecipes(repository),
      getCategories: GetCategories(repository),
      getRecipesByCategory: GetRecipesByCategory(repository),
    );
    final states = <RecipesState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const LoadRandomRecipes());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    bloc.add(const SearchRecipesRequested('Chicken'));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    repository.emptySearch = true;
    bloc.add(const SearchRecipesRequested('No match'));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    bloc.add(const LoadRecipeDetail('52795'));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    bloc.add(const LoadCategories());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    bloc.add(const LoadRecipesByCategory('Chicken'));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(
      states.any((s) => s.recipes.isNotEmpty && s.recipes.first.id == '52795'),
      isTrue,
    );
    expect(states.any((s) => s.searchResults.length == 1), isTrue);
    expect(
      states.any(
        (s) => s.status == RecipesStatus.success && s.searchResults.isEmpty,
      ),
      isTrue,
    );
    expect(states.any((s) => s.selectedRecipe?.id == '52795'), isTrue);
    expect(
      states.any((s) => s.categories.any((c) => c.name == 'Chicken')),
      isTrue,
    );
    expect(
      states.any((s) => s.categoryRecipes['Chicken']?.isNotEmpty == true),
      isTrue,
    );

    await subscription.cancel();
    await bloc.close();
  });

  test(
    'BLoC collects six random recipes and tolerates a failed request',
    () async {
      final repository = _MultiRandomRepository();
      final bloc = RecipesBloc(
        getRandomRecipe: GetRandomRecipe(repository),
        getRecipeDetail: GetRecipeDetail(repository),
        searchRecipes: SearchRecipes(repository),
        getCategories: GetCategories(repository),
        getRecipesByCategory: GetRecipesByCategory(repository),
      );
      final completed = bloc.stream.firstWhere(
        (state) =>
            state.status == RecipesStatus.success ||
            state.status == RecipesStatus.failure,
      );

      bloc.add(const LoadRandomRecipes());
      final state = await completed;

      expect(state.status, RecipesStatus.success);
      expect(state.recipes, hasLength(6));
      expect(repository.randomCalls, 9);

      await bloc.close();
    },
  );
}

class _FailingRemote implements RecipeRemoteDataSource {
  @override
  Future<RecipeModel> getRandomRecipe() async =>
      throw const NetworkException('offline');

  @override
  Future<RecipeModel> getRecipeDetail(String id) async =>
      throw const NetworkException('offline');

  @override
  Future<List<RecipeModel>> searchRecipes(String query) async =>
      throw const NetworkException('offline');

  @override
  Future<List<RecipeModel>> getRecipesByCategory(String category) async =>
      throw const NetworkException('offline');
}

class _FailingCategoryRemote implements CategoryRemoteDataSource {
  @override
  Future<List<CategoryModel>> getCategories() async =>
      throw const NetworkException('offline');
}
