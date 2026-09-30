import 'package:flutter/material.dart';

import 'detail_page.dart';
import 'home_page.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => const HomePage());

      case "/detail_screen":
        final String recipeId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => DetailPage(recipeId: recipeId),
        );
    }

    return MaterialPageRoute(builder: (_) => const HomePage());
  }
}
