import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/domain/entities/recipe_entity.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/presentation/widgets/recipe_widget.dart';
import 'package:flutter_recipes_clean_streams/features/recipes/presentation/widgets/discovery_widgets.dart';

void main() {
  for (final horizontal in [false, true]) {
    testWidgets(
      'temporary favorite resets after widget recreation (horizontal=$horizontal)',
      (tester) async {
        Widget card() => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 230,
              height: 310,
              child: horizontal
                  ? RecipeHorizontalCard(
                      recipe: const RecipeEntity(id: '1', name: 'Sample'),
                      onTap: () {},
                    )
                  : RecipeWidget(
                      recipe: const RecipeEntity(id: '1', name: 'Sample'),
                      tap: () {},
                    ),
            ),
          ),
        );
        await tester.pumpWidget(card());
        expect(find.byTooltip('Guardar receta'), findsOneWidget);
        await tester.tap(find.byTooltip('Guardar receta'));
        await tester.pump();
        expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(card());
        expect(find.byTooltip('Guardar receta'), findsOneWidget);
        expect(find.byTooltip('Quitar de favoritos'), findsNothing);
      },
    );
  }
}
