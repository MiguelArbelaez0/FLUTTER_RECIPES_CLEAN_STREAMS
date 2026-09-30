import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection/injection_container.dart';
import '../bloc/recipes_bloc.dart';
import '../bloc/recipes_event.dart';
import '../bloc/recipes_state.dart';
import '../widgets/recipe_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<RecipesBloc>()..add(const LoadRandomRecipes()),
    child: Builder(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: BlocBuilder<RecipesBloc, RecipesState>(
            builder: (context, state) {
              final searching = _searchController.text.trim().length >= 2;
              final displayedRecipes = searching
                  ? state.searchResults
                  : state.recipes;
              final isLoading = state.status == RecipesStatus.loading;
              final failed = state.status == RecipesStatus.failure;

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppPalette.primarySoft,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              color: AppPalette.primary,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Text(
                            'Sazón',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          IconButton.filledTonal(
                            tooltip: 'Descubrir recetas',
                            onPressed: isLoading
                                ? null
                                : () => context.read<RecipesBloc>().add(
                                    const LoadRandomRecipes(refresh: true),
                                  ),
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 25, 22, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Qué quieres\ncocinar hoy?',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Encuentra inspiración para tu próxima comida.',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppPalette.muted),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onChanged: (query) => context
                                .read<RecipesBloc>()
                                .add(SearchRecipesRequested(query)),
                            decoration: InputDecoration(
                              hintText: 'Busca una receta o ingrediente',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Limpiar búsqueda',
                                      onPressed: () {
                                        _searchController.clear();
                                        context.read<RecipesBloc>().add(
                                          const SearchRecipesRequested(''),
                                        );
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 14),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  searching ? 'Resultados' : 'Descubre recetas',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  searching
                                      ? 'Ideas para “${_searchController.text.trim()}”'
                                      : 'Un poco de inspiración para hoy',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          if (!searching)
                            TextButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () => context.read<RecipesBloc>().add(
                                      const LoadRandomRecipes(refresh: true),
                                    ),
                              icon: const Icon(Icons.auto_awesome, size: 17),
                              label: const Text('Otra tanda'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (failed && displayedRecipes.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _MessageState(
                        icon: Icons.wifi_off_rounded,
                        title: 'No pudimos cargar las recetas',
                        message:
                            state.errorMessage ??
                            'Revisa tu conexión e inténtalo de nuevo.',
                        actionLabel: 'Reintentar',
                        onAction: () => context.read<RecipesBloc>().add(
                          searching
                              ? SearchRecipesRequested(_searchController.text)
                              : const LoadRandomRecipes(refresh: true),
                        ),
                      ),
                    )
                  else if (isLoading && displayedRecipes.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(22, 2, 22, 30),
                      sliver: SliverGrid.builder(
                        itemCount: 6,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 300,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15,
                              childAspectRatio: 0.72,
                            ),
                        itemBuilder: (_, _) => const _RecipeSkeleton(),
                      ),
                    )
                  else if (displayedRecipes.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _MessageState(
                        icon: searching
                            ? Icons.search_off
                            : Icons.menu_book_outlined,
                        title: searching
                            ? 'No encontramos recetas'
                            : 'Aún no hay recetas',
                        message: searching
                            ? 'Prueba con otro nombre o ingrediente.'
                            : 'Toca “Otra tanda” para descubrir algo nuevo.',
                        actionLabel: searching
                            ? 'Limpiar búsqueda'
                            : 'Descubrir recetas',
                        onAction: searching
                            ? () {
                                _searchController.clear();
                                context.read<RecipesBloc>().add(
                                  const SearchRecipesRequested(''),
                                );
                                setState(() {});
                              }
                            : () => context.read<RecipesBloc>().add(
                                const LoadRandomRecipes(refresh: true),
                              ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(22, 2, 22, 30),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.crossAxisExtent;
                          final count = width >= 1000
                              ? 4
                              : width >= 650
                              ? 3
                              : 2;
                          return SliverGrid.builder(
                            itemCount: displayedRecipes.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: count,
                                  mainAxisSpacing: 15,
                                  crossAxisSpacing: 15,
                                  childAspectRatio: width < 380 ? 0.68 : 0.72,
                                ),
                            itemBuilder: (context, index) => RecipeWidget(
                              recipe: displayedRecipes[index],
                              tap: () => Navigator.pushNamed(
                                context,
                                '/detail_screen',
                                arguments: displayedRecipes[index].id,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

class _RecipeSkeleton extends StatelessWidget {
  const _RecipeSkeleton();

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Expanded(flex: 6, child: Container(color: AppPalette.border)),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 9,
                  width: 62,
                  decoration: BoxDecoration(
                    color: AppPalette.border,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 11),
                Container(
                  height: 13,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppPalette.border,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  height: 13,
                  width: 90,
                  decoration: BoxDecoration(
                    color: AppPalette.border,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: AppPalette.secondary),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    ),
  );
}
