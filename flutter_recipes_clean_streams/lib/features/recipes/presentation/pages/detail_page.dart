import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/recipes_bloc.dart';
import '../bloc/recipes_event.dart';
import '../bloc/recipes_state.dart';
import '../../../../injection/injection_container.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.recipeId});

  final String recipeId;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  final List<String> _titles = const ['Preparation', 'Ingredients', 'About'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<RecipesBloc>()..add(LoadRecipeDetail(widget.recipeId)),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.orange,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        body: BlocBuilder<RecipesBloc, RecipesState>(
          builder: (context, state) {
            if (state.detailStatus == RecipeDetailStatus.loading ||
                state.detailStatus == RecipeDetailStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.detailStatus == RecipeDetailStatus.failure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Could not load this recipe.'),
                    ElevatedButton(
                      onPressed: () => context.read<RecipesBloc>().add(
                        LoadRecipeDetail(widget.recipeId),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final recipe = state.selectedRecipe;
            if (recipe == null) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe.imageUrl != null)
                  Expanded(
                    child: Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => const Placeholder(),
                    ),
                  )
                else
                  const Expanded(child: Placeholder()),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _titles.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          _titles[index],
                          style: TextStyle(
                            fontSize: 18,
                            color: _currentPageIndex == index
                                ? Colors.orange
                                : Colors.grey,
                            fontWeight: _currentPageIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPageIndex = index),
                    children: [
                      ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Text(
                            recipe.instructions?.trim().isNotEmpty == true
                                ? recipe.instructions!.trim()
                                : 'No instructions available.',
                            style: const TextStyle(fontSize: 17, height: 1.5),
                          ),
                        ],
                      ),
                      ListView.builder(
                        itemCount: recipe.ingredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = recipe.ingredients[index];
                          return ListTile(
                            title: Text(ingredient.name),
                            subtitle: ingredient.measure == null
                                ? null
                                : Text(ingredient.measure!),
                          );
                        },
                      ),
                      ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          ListTile(
                            title: const Text('Category'),
                            subtitle: Text(recipe.category ?? 'Unknown'),
                          ),
                          ListTile(
                            title: const Text('Cuisine'),
                            subtitle: Text(recipe.area ?? 'Unknown'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
