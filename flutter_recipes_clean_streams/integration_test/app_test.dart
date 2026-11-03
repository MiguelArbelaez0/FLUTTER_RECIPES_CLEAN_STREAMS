import 'package:flutter/material.dart';
import 'package:flutter_recipes_clean_streams/core/error/failures/failure.dart';
import 'package:flutter_recipes_clean_streams/core/utils/request_cancellation.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/entities/category_entity.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/entities/recipe_entity.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:flutter_recipes_clean_streams/injection/injection_container.dart';
import 'package:flutter_recipes_clean_streams/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('discover, search, open instructions and return on device', (
    tester,
  ) async {
    configureDependencies();
    await getIt.unregister<RecipeRepository>();
    getIt.registerSingleton<RecipeRepository>(_Recipes());
    addTearDown(getIt.reset);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Sazón'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Soup');
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    for (
      var i = 0;
      i < 15 && find.text('Vegetable soup').hitTestable().evaluate().isEmpty;
      i++
    ) {
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -120),
      );
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Vegetable soup').hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('Ingredientes'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Simmer and serve.'), 120);
    expect(find.text('Simmer and serve.'), findsOneWidget);
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('device search failure recovers on retry', (tester) async {
    configureDependencies();
    final repository = _Recipes();
    await getIt.unregister<RecipeRepository>();
    getIt.registerSingleton<RecipeRepository>(repository);
    addTearDown(getIt.reset);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    repository.offline = true;
    await tester.enterText(find.byType(TextField), 'Soup');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    final error = find.text('No pudimos completar la búsqueda.');
    await tester.scrollUntilVisible(
      error,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(error, findsOneWidget);
    repository.offline = false;
    final retry = find.text('Reintentar');
    await tester.ensureVisible(retry);
    await tester.pumpAndSettle();
    expect(retry.hitTestable(), findsOneWidget);
    await tester.tap(retry.hitTestable());
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(error, findsNothing);
    expect(repository.searchCalls, 2);
    expect(find.text('Vegetable soup'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _Recipes implements RecipeRepository {
  bool offline = false;
  int searchCalls = 0;
  static const recipe = RecipeEntity(
    id: '1',
    name: 'Vegetable soup',
    instructions: 'Simmer and serve.',
    ingredients: [IngredientEntity(name: 'Carrot', measure: '2')],
  );
  @override
  Future<RecipeEntity> getRandomRecipe() async => recipe;
  @override
  Future<RecipeEntity> getRecipeDetail(String id) async => recipe;
  @override
  Future<List<RecipeEntity>> searchRecipes(
    String query, {
    RequestCancellation? cancellation,
  }) async {
    searchCalls++;
    if (offline) throw const NetworkFailure('Simulated connection failure');
    return [recipe];
  }

  @override
  Future<List<CategoryEntity>> getCategories() async => const [
    CategoryEntity(id: '1', name: 'Vegetarian'),
  ];
  @override
  Future<List<RecipeEntity>> getRecipesByCategory(String category) async => [
    recipe,
  ];
}
