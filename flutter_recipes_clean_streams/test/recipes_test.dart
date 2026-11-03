import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/presentation/pages/detail_page.dart';
import 'package:flutter_recipes_clean_streams/core/error/exceptions/exceptions.dart';
import 'package:flutter_recipes_clean_streams/core/error/failures/failure.dart';
import 'package:flutter_recipes_clean_streams/core/network/api_client.dart';
import 'package:flutter_recipes_clean_streams/core/utils/request_cancellation.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/data/datasources/category_remote_data_source.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/data/datasources/category_remote_data_source_impl.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/data/datasources/recipe_remote_data_source.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/data/datasources/recipe_remote_data_source_impl.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/data/models/category_model.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/data/models/recipe_model.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/data/repositories/recipe_repository_impl.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/entities/category_entity.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/entities/recipe_entity.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/usecases/get_categories.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/usecases/get_random_recipe.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/usecases/get_recipe_detail.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/usecases/get_recipes_by_category.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/usecases/search_recipes.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/presentation/bloc/recipes_bloc.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/presentation/bloc/recipes_event.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/presentation/bloc/recipes_state.dart';
import 'package:flutter_recipes_clean_streams/injection/injection_container.dart';
import 'package:flutter_recipes_clean_streams/main.dart';
import 'package:flutter_test/flutter_test.dart';

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
  Future<List<RecipeModel>> searchRecipes(
    String query, {
    RequestCancellation? cancellation,
  }) async => emptySearch ? [] : [recipe];

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
  Future<List<RecipeEntity>> searchRecipes(
    String query, {
    RequestCancellation? cancellation,
  }) async => emptySearch ? [] : [recipe];

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
  _StaticAdapter(
    this.body, {
    this.statusCode = 200,
    this.failNetwork = false,
    this.errorType,
  });

  final Object body;
  final int statusCode;
  final bool failNetwork;
  final DioExceptionType? errorType;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (failNetwork || errorType != null) {
      throw DioException(
        requestOptions: options,
        type: errorType ?? DioExceptionType.connectionError,
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
  RecipesBloc makeBloc(RecipeRepository repository) => RecipesBloc(
    getRandomRecipe: GetRandomRecipe(repository),
    getRecipeDetail: GetRecipeDetail(repository),
    searchRecipes: SearchRecipes(repository),
    getCategories: GetCategories(repository),
    getRecipesByCategory: GetRecipesByCategory(repository),
  );

  testWidgets('debounce calls only the latest query and clears short input', (
    tester,
  ) async {
    final repository = _ControlledRepository();
    final bloc = makeBloc(repository);
    bloc.add(const SearchRecipesRequested('ch'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    bloc.add(const SearchRecipesRequested('chicken'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 349));
    expect(repository.searches, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(repository.searches.keys, ['chicken']);
    repository.searches['chicken']!.complete([repository.recipe]);
    await tester.pump();
    expect(bloc.state.searchStatus, RecipesStatus.success);
    expect(bloc.state.status, RecipesStatus.initial);
    bloc.add(const SearchRecipesRequested('c'));
    await tester.pump();
    expect(bloc.state.searchResults, isEmpty);
    expect(bloc.state.searchStatus, RecipesStatus.initial);
    await tester.runAsync(bloc.close);
  });

  testWidgets(
    'new input cancels immediately and ignores stale success and failure',
    (tester) async {
      final repository = _ControlledRepository();
      final bloc = makeBloc(repository);
      bloc.add(const SearchRecipesRequested('old'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      bloc.add(const SearchRecipesRequested('new'));
      await tester.pump();
      expect(repository.cancellations['old']!.isCancelled, isTrue);
      repository.searches['old']!.complete([repository.recipe]);
      await tester.pump();
      expect(bloc.state.searchResults, isEmpty);
      await tester.pump(const Duration(milliseconds: 350));
      repository.searches['new']!.completeError(
        const NetworkFailure('offline'),
      );
      await tester.pump();
      expect(bloc.state.searchStatus, RecipesStatus.failure);
      bloc.add(const SearchRecipesRequested('retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      repository.searches['retry']!.complete([]);
      await tester.pump();
      expect(bloc.state.searchStatus, RecipesStatus.success);
      expect(bloc.state.searchResults, isEmpty);
      await tester.runAsync(bloc.close);
    },
  );

  testWidgets('closing during debounce cancels pending work', (tester) async {
    final repository = _ControlledRepository();
    final bloc = makeBloc(repository);
    bloc.add(const SearchRecipesRequested('chicken'));
    await tester.pump();
    await tester.runAsync(bloc.close);
    await tester.pump(const Duration(seconds: 1));
    expect(repository.searches, isEmpty);
  });

  testWidgets('late detail never replaces a newer detail', (tester) async {
    final repository = _ControlledRepository();
    final bloc = makeBloc(repository);
    bloc.add(const LoadRecipeDetail('old'));
    await tester.pump();
    bloc.add(const LoadRecipeDetail('new'));
    await tester.pump();
    repository.details['new']!.complete(
      const RecipeEntity(id: 'new', name: 'New'),
    );
    await tester.pump();
    repository.details['old']!.completeError(
      const NetworkFailure('late failure'),
    );
    await tester.pump();
    expect(bloc.state.selectedRecipe!.id, 'new');
    expect(bloc.state.detailStatus, RecipeDetailStatus.success);
    await tester.runAsync(bloc.close);
  });

  test('invalid recipes and sparse ingredients are validated', () {
    expect(
      () => RecipeModel.fromJson({'idMeal': 1, 'strMeal': 'Meal'}),
      throwsFormatException,
    );
    final recipe = RecipeModel.fromJson({
      ..._meal,
      'strIngredient1': '  ',
      'strIngredient20': ' Salt ',
      'strMeasure20': ' ',
    });
    expect(recipe.ingredients.single.name, 'Salt');
    expect(recipe.ingredients.single.measure, isNull);
  });

  test('malformed meal list entries become parsing failures', () async {
    for (final body in [
      {'meals': 7},
      {
        'meals': [null],
      },
      {
        'meals': [{}],
      },
    ]) {
      final repository = RecipeRepositoryImpl(
        _dataSource(_StaticAdapter(body)),
        _FakeCategoryRemote(),
      );
      await expectLater(
        repository.searchRecipes('dish'),
        throwsA(isA<ParsingFailure>()),
      );
    }
  });

  test('Dio transport is cancelled through the domain signal', () async {
    final adapter = _PendingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'))
      ..httpClientAdapter = adapter;
    final cancellation = RequestCancellation();
    final request = RecipeRemoteDataSourceImpl(ApiClient(dio: dio))
        .searchRecipes('dish', cancellation: cancellation);
    final expectation = expectLater(request, throwsA(isA<NetworkException>()));
    await adapter.started.future;
    cancellation.cancel();
    await expectation;
    await adapter.cancelled.future;
    dio.close(force: true);
  });

  for (final width in [320.0, 800.0, 1280.0]) {
    testWidgets('home search and detail navigation at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      configureDependencies();
      await getIt.unregister<RecipeRepository>();
      getIt.registerSingleton<RecipeRepository>(_FakeRepository());
      addTearDown(getIt.reset);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.text('Sazón'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Chicken');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      for (
        var i = 0;
        i < 12 && find.text('Chicken Handi').hitTestable().evaluate().isEmpty;
        i++
      ) {
        await tester.drag(
          find.byType(CustomScrollView).first,
          const Offset(0, -150),
        );
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Chicken Handi').hitTestable().first);
      await tester.pumpAndSettle();
      expect(find.text('Ingredientes'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Cook the chicken.'), 150);
      expect(find.text('Cook the chicken.'), findsOneWidget);

      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final type in [
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
  ]) {
    test('repository maps $type to recoverable network failure', () async {
      final repository = RecipeRepositoryImpl(
        _dataSource(_StaticAdapter({}, errorType: type)),
        _FakeCategoryRemote(),
      );
      await expectLater(
        repository.searchRecipes('dish'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  }

  test(
    'category parsing normalizes optional fields and rejects invalid names',
    () {
      final category = CategoryModel.fromJson({
        'idCategory': ' 1 ',
        'strCategory': ' Chicken ',
        'strCategoryThumb': ' ',
      });
      expect(category.toEntity().name, 'Chicken');
      expect(category.imageUrl, isNull);
      expect(
        () => CategoryModel.fromJson({'idCategory': '1', 'strCategory': 7}),
        throwsFormatException,
      );
    },
  );

  test('category malformed and server responses are translated', () async {
    await expectLater(
      _categoryDataSource(
        _StaticAdapter({
          'categories': [null],
        }),
      ).getCategories(),
      throwsA(isA<ParsingException>()),
    );
    await expectLater(
      _categoryDataSource(_StaticAdapter({}, statusCode: 503)).getCategories(),
      throwsA(isA<ServerException>()),
    );
  });

  testWidgets('category failures can retry, success caches the list', (
    tester,
  ) async {
    final repository = _RetryRepository();
    final bloc = makeBloc(repository);
    bloc.add(const LoadRecipesByCategory('Chicken'));
    await tester.pump();
    expect(bloc.state.categoryErrors, contains('Chicken'));
    expect(bloc.state.categoryLoading, isEmpty);
    bloc.add(const LoadRecipesByCategory('Chicken'));
    await tester.pump();
    expect(bloc.state.categoryRecipes['Chicken'], isNotEmpty);
    expect(bloc.state.categoryErrors, isEmpty);
    bloc.add(const LoadRecipesByCategory('Chicken'));
    await tester.pump();
    expect(repository.calls, 2);
    await tester.runAsync(bloc.close);
  });

  testWidgets('home connection failure offers retry and recovers', (
    tester,
  ) async {
    final repository = _OfflineRepository();
    configureDependencies();
    await getIt.unregister<RecipeRepository>();
    getIt.registerSingleton<RecipeRepository>(repository);
    addTearDown(getIt.reset);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    for (
      var i = 0;
      i < 12 && find.text('Reintentar').hitTestable().evaluate().isEmpty;
      i++
    ) {
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -150),
      );
      await tester.pumpAndSettle();
    }
    repository.offline = false;
    await tester.tap(find.text('Reintentar').hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('Chicken Handi'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('detail connection failure offers retry and recovers', (
    tester,
  ) async {
    final repository = _OfflineRepository();
    configureDependencies();
    await getIt.unregister<RecipeRepository>();
    getIt.registerSingleton<RecipeRepository>(repository);
    addTearDown(getIt.reset);
    await tester.pumpWidget(
      const MaterialApp(home: DetailPage(recipeId: '52795')),
    );
    await tester.pumpAndSettle();
    expect(find.text('offline'), findsOneWidget);
    repository.offline = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Ingredientes'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

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

  test('BLoC emits home, search, empty, detail and category states', () async {
    final repository = _FakeRepository();
    final bloc = makeBloc(repository);
    Future<RecipesState> dispatch(
      RecipesEvent event,
      bool Function(RecipesState) done,
    ) {
      final completed = bloc.stream.firstWhere(done);
      bloc.add(event);
      return completed;
    }

    expect(
      (await dispatch(
        const LoadRandomRecipes(),
        (s) => s.status == RecipesStatus.success,
      )).recipes,
      isNotEmpty,
    );
    expect(
      (await dispatch(
        const SearchRecipesRequested('Chicken'),
        (s) => s.searchStatus == RecipesStatus.success,
      )).searchResults,
      hasLength(1),
    );
    repository.emptySearch = true;
    expect(
      (await dispatch(
        const SearchRecipesRequested('No match'),
        (s) =>
            s.searchStatus == RecipesStatus.success && s.searchResults.isEmpty,
      )).searchResults,
      isEmpty,
    );
    expect(
      (await dispatch(
        const LoadRecipeDetail('52795'),
        (s) => s.detailStatus == RecipeDetailStatus.success,
      )).selectedRecipe!.id,
      '52795',
    );
    expect(
      (await dispatch(
        const LoadCategories(),
        (s) => s.categoriesStatus == CategoriesStatus.success,
      )).categories.single.name,
      'Chicken',
    );
    expect(
      (await dispatch(
        const LoadRecipesByCategory('Chicken'),
        (s) => s.categoryRecipes.containsKey('Chicken'),
      )).categoryRecipes['Chicken'],
      isNotEmpty,
    );
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
  Future<List<RecipeModel>> searchRecipes(
    String query, {
    RequestCancellation? cancellation,
  }) async => throw const NetworkException('offline');

  @override
  Future<List<RecipeModel>> getRecipesByCategory(String category) async =>
      throw const NetworkException('offline');
}

class _FailingCategoryRemote implements CategoryRemoteDataSource {
  @override
  Future<List<CategoryModel>> getCategories() async =>
      throw const NetworkException('offline');
}

class _ControlledRepository extends _FakeRepository {
  final searches = <String, Completer<List<RecipeEntity>>>{};
  final cancellations = <String, RequestCancellation>{};
  final details = <String, Completer<RecipeEntity>>{};
  @override
  Future<List<RecipeEntity>> searchRecipes(
    String query, {
    RequestCancellation? cancellation,
  }) {
    cancellations[query] = cancellation!;
    return (searches[query] = Completer<List<RecipeEntity>>()).future;
  }

  @override
  Future<RecipeEntity> getRecipeDetail(String id) =>
      (details[id] = Completer<RecipeEntity>()).future;
}

class _PendingAdapter implements HttpClientAdapter {
  final started = Completer<void>();
  final cancelled = Completer<void>();
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    started.complete();
    await cancelFuture;
    cancelled.complete();
    throw DioException(requestOptions: options, type: DioExceptionType.cancel);
  }

  @override
  void close({bool force = false}) {}
}

class _RetryRepository extends _FakeRepository {
  int calls = 0;
  @override
  Future<List<RecipeEntity>> getRecipesByCategory(String category) async {
    if (++calls == 1) throw const NetworkFailure('offline');
    return [recipe];
  }
}

class _OfflineRepository extends _FakeRepository {
  bool offline = true;
  @override
  Future<RecipeEntity> getRandomRecipe() async {
    if (offline) throw const NetworkFailure('offline');
    return recipe;
  }

  @override
  Future<RecipeEntity> getRecipeDetail(String id) async {
    if (offline) throw const NetworkFailure('offline');
    return recipe;
  }
}
