import 'package:flutter/material.dart';

import 'detail_page.dart';
import 'home_page.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => const HomePage());

      case "/detail_screen":
        final argument = settings.arguments;
        if (argument is! String || argument.trim().isEmpty) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Ruta de receta inválida.')),
            ),
          );
        }
        final recipeId = argument.trim();
        return MaterialPageRoute(
          builder: (context) => DetailPage(recipeId: recipeId),
        );
    }

    return MaterialPageRoute(builder: (_) => const HomePage());
  }
}
