import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/recipe_widget.dart';
import '../widgets/search_widget.dart';

import '../bloc/recipes_bloc.dart';
import '../bloc/recipes_event.dart';
import '../bloc/recipes_state.dart';
import '../../../../injection/injection_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RecipesBloc>()..add(const LoadRandomRecipes()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: 'Refresh recipes',
                color: Colors.orange,
                onPressed: () => context.read<RecipesBloc>().add(
                  const LoadRandomRecipes(refresh: true),
                ),
                icon: const Icon(Icons.refresh),
              ),
              Container(
                margin: EdgeInsets.only(right: 20),
                child: IconButton(
                  color: Colors.orange,
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: SearchWidget(context.read<RecipesBloc>()),
                    );
                  },
                  icon: Icon(Icons.search_outlined, size: 30),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<RecipesBloc, RecipesState>(
                  builder: (context, state) {
                    if (state.status == RecipesStatus.loading &&
                        state.recipes.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == RecipesStatus.failure &&
                        state.recipes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.errorMessage ??
                                  'No se pudieron cargar las recetas',
                            ),
                            ElevatedButton(
                              onPressed: () => context.read<RecipesBloc>().add(
                                const LoadRandomRecipes(refresh: true),
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }
                    final recipes = state.recipes;
                    if (recipes.isEmpty) {
                      return Center(
                        child: ElevatedButton(
                          onPressed: () => context.read<RecipesBloc>().add(
                            const LoadRandomRecipes(refresh: true),
                          ),
                          child: const Text('Cargar recetas'),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 10,
                        right: 10,
                      ),
                      itemCount: recipes.length,
                      itemBuilder: (BuildContext context, int index) {
                        return RecipeWidget(
                          recipe: recipes[index],
                          tap: () {
                            Navigator.pushNamed(
                              context,
                              "/detail_screen",
                              arguments: recipes[index].id,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
