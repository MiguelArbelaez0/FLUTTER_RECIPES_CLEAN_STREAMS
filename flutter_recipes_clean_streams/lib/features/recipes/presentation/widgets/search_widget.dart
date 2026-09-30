import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/recipes_bloc.dart';
import '../bloc/recipes_event.dart';
import '../bloc/recipes_state.dart';

import 'recipe_widget.dart';

class SearchWidget extends SearchDelegate {
  final RecipesBloc _recipesBloc;
  SearchWidget(this._recipesBloc);
  // final TextEditingController _queryTextController = TextEditingController();

  // String get query => _queryTextController.text;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _recipesBloc.add(SearchRecipesRequested(query));
    return BlocProvider.value(
      value: _recipesBloc,
      child: BlocBuilder<RecipesBloc, RecipesState>(
        builder: (context, state) {
          if (state.status == RecipesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == RecipesStatus.failure) {
            return Center(child: Text(state.errorMessage ?? 'Error al buscar'));
          }
          final recipes = state.searchResults;
          if (recipes.isEmpty) {
            return const Center(
              child: Text('No recipes found. Try another search.'),
            );
          }
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) => RecipeWidget(
              recipe: recipes[index],
              tap: () => Navigator.pushNamed(
                context,
                '/detail_screen',
                arguments: recipes[index].id,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
