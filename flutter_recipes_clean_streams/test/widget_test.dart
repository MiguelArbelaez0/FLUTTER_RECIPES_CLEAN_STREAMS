import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/entities/recipe_entity.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/presentation/widgets/recipe_widget.dart';

void main() {
  testWidgets('recipe card displays its title and responds to taps', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecipeWidget(
            recipe: const RecipeEntity(id: '1', name: 'Vegetable soup'),
            tap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Vegetable soup'), findsOneWidget);
    await tester.tap(find.text('Vegetable soup'));
    expect(tapped, isTrue);
  });
}
