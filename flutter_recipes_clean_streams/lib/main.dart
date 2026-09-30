import 'package:flutter/material.dart';

import 'features/recipes/presentation/pages/routes_app.dart';

import 'injection/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe Search',
      theme: ThemeData(primarySwatch: Colors.blue),
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
