import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection/injection_container.dart';
import '../../domain/entities/recipe_entity.dart';
import '../bloc/recipes_bloc.dart';
import '../bloc/recipes_event.dart';
import '../bloc/recipes_state.dart';
import '../widgets/discovery_widgets.dart';
import '../widgets/recipe_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _popularCategories = [
    'Chicken',
    'Beef',
    'Dessert',
    'Pasta',
    'Seafood',
    'Vegetarian',
  ];

  final _searchController = TextEditingController();
  String? _selectedCategory;
  bool _requestedPopularCategories = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchChanged);
  }

  void _searchChanged() => setState(() {});

  @override
  void dispose() {
    _searchController.removeListener(_searchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<RecipesBloc>()..add(const LoadHome()),
    child: BlocListener<RecipesBloc, RecipesState>(
      listenWhen: (previous, current) =>
          previous.categoriesStatus != CategoriesStatus.success &&
          current.categoriesStatus == CategoriesStatus.success,
      listener: (context, state) {
        if (_requestedPopularCategories) return;
        _requestedPopularCategories = true;
        final availableNames = state.categories
            .map((category) => category.name.toLowerCase())
            .toSet();
        for (final category in _popularCategories) {
          if (availableNames.contains(category.toLowerCase())) {
            context.read<RecipesBloc>().add(LoadRecipesByCategory(category));
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1220),
                child: BlocBuilder<RecipesBloc, RecipesState>(
                  builder: (context, state) {
                    final query = _searchController.text.trim();
                    final searching = query.length >= 2;
                    final selectedRecipes = _selectedCategory == null
                        ? const <RecipeEntity>[]
                        : state.categoryRecipes[_selectedCategory] ??
                              const <RecipeEntity>[];
                    final wide = viewport.maxWidth >= 760;

                    return CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            wide ? 36 : 22,
                            18,
                            wide ? 36 : 22,
                            0,
                          ),
                          sliver: SliverToBoxAdapter(child: HomeHeader()),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            wide ? 36 : 22,
                            28,
                            wide ? 36 : 22,
                            0,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: _WelcomeBanner(
                              searching: searching,
                              controller: _searchController,
                              onChanged: (value) => context
                                  .read<RecipesBloc>()
                                  .add(SearchRecipesRequested(value)),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            wide ? 36 : 22,
                            30,
                            wide ? 36 : 22,
                            0,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeader(
                                  title: 'Explora por categoría',
                                  subtitle: '¿Qué se te antoja preparar?',
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 132,
                                  child:
                                      state.categoriesStatus ==
                                              CategoriesStatus.loading ||
                                          state.categoriesStatus ==
                                              CategoriesStatus.initial
                                      ? ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 6,
                                          separatorBuilder: (_, _) =>
                                              const SizedBox(width: 10),
                                          itemBuilder: (_, _) =>
                                              const CategoryCardSkeleton(),
                                        )
                                      : state.categories.isEmpty
                                      ? _CategoryError(
                                          onRetry: () => context
                                              .read<RecipesBloc>()
                                              .add(const LoadCategories()),
                                        )
                                      : ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: state.categories.length,
                                          separatorBuilder: (_, _) =>
                                              const SizedBox(width: 10),
                                          itemBuilder: (context, index) {
                                            final category =
                                                state.categories[index];
                                            return CategoryCard(
                                              category: category,
                                              selected:
                                                  category.name ==
                                                  _selectedCategory,
                                              onTap: () {
                                                final wasSelected =
                                                    category.name ==
                                                    _selectedCategory;
                                                setState(
                                                  () => _selectedCategory =
                                                      wasSelected
                                                      ? null
                                                      : category.name,
                                                );
                                                if (!wasSelected) {
                                                  context
                                                      .read<RecipesBloc>()
                                                      .add(
                                                        LoadRecipesByCategory(
                                                          category.name,
                                                        ),
                                                      );
                                                }
                                              },
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (searching)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              wide ? 36 : 22,
                              30,
                              wide ? 36 : 22,
                              0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _SearchResults(
                                query: query,
                                recipes: state.searchResults,
                                loading: state.status == RecipesStatus.loading,
                                failed: state.status == RecipesStatus.failure,
                                onClear: () {
                                  _searchController.clear();
                                  context.read<RecipesBloc>().add(
                                    const SearchRecipesRequested(''),
                                  );
                                },
                                onRetry: () => context.read<RecipesBloc>().add(
                                  SearchRecipesRequested(query),
                                ),
                                onOpenRecipe: (recipe) =>
                                    _openRecipe(context, recipe),
                              ),
                            ),
                          ),
                        if (_selectedCategory != null)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              wide ? 36 : 22,
                              28,
                              wide ? 36 : 22,
                              0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _CategorySelection(
                                name: _selectedCategory!,
                                recipes: selectedRecipes,
                                loading: state.categoryLoading.contains(
                                  _selectedCategory,
                                ),
                                error: state.categoryErrors[_selectedCategory],
                                onClose: () =>
                                    setState(() => _selectedCategory = null),
                                onRetry: () => context.read<RecipesBloc>().add(
                                  LoadRecipesByCategory(_selectedCategory!),
                                ),
                                onOpenRecipe: (recipe) =>
                                    _openRecipe(context, recipe),
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            wide ? 36 : 22,
                            32,
                            wide ? 36 : 22,
                            0,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeader(
                                  title: 'Recetas destacadas',
                                  subtitle: 'Favoritas para inspirarte hoy',
                                ),
                                const SizedBox(height: 14),
                                if (state.status == RecipesStatus.loading &&
                                    state.recipes.isEmpty)
                                  _FeaturedSkeletons()
                                else if (state.recipes.isEmpty)
                                  _InlineNotice(
                                    icon: state.status == RecipesStatus.failure
                                        ? Icons.cloud_off_outlined
                                        : Icons.restaurant_menu,
                                    message:
                                        state.status == RecipesStatus.failure
                                        ? (state.errorMessage ??
                                              'No pudimos cargar las recetas.')
                                        : 'Estamos preparando algo delicioso.',
                                    action: () =>
                                        context.read<RecipesBloc>().add(
                                          const LoadRandomRecipes(
                                            refresh: true,
                                          ),
                                        ),
                                    actionLabel:
                                        state.status == RecipesStatus.failure
                                        ? 'Reintentar'
                                        : 'Descubrir',
                                  )
                                else
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final count = constraints.maxWidth >= 1020
                                          ? 4
                                          : constraints.maxWidth >= 680
                                          ? 3
                                          : 2;
                                      final recipes = state.recipes
                                          .take(count == 2 ? 2 : 4)
                                          .toList();
                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: recipes.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: count,
                                              crossAxisSpacing: 14,
                                              mainAxisSpacing: 14,
                                              childAspectRatio:
                                                  constraints.maxWidth < 400
                                                  ? .68
                                                  : .76,
                                            ),
                                        itemBuilder: (context, index) =>
                                            RecipeWidget(
                                              recipe: recipes[index],
                                              tap: () => _openRecipe(
                                                context,
                                                recipes[index],
                                              ),
                                            ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            wide ? 36 : 22,
                            34,
                            wide ? 36 : 22,
                            0,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeader(
                                  title: 'Descubre algo nuevo',
                                  subtitle: 'Recetas aleatorias para salir de la rutina',
                                  actionLabel: 'Ver más',
                                  onAction: () =>
                                      context.read<RecipesBloc>().add(
                                        const LoadRandomRecipes(refresh: true),
                                      ),
                                ),
                                const SizedBox(height: 14),
                                if (state.status == RecipesStatus.loading &&
                                    state.recipes.isEmpty)
                                  _HorizontalSkeletons()
                                else
                                  _HorizontalRecipes(
                                    recipes: state.recipes
                                        .skip(state.recipes.length > 2 ? 2 : 0)
                                        .toList(),
                                    loading:
                                        state.status == RecipesStatus.loading,
                                    onOpenRecipe: (recipe) =>
                                        _openRecipe(context, recipe),
                                    emptyLabel: 'Pulsa “Ver más” para cargar nuevas recetas.',
                                  ),
                              ],
                            ),
                          ),
                        ),
                        for (final categoryName in _popularCategories)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              wide ? 36 : 22,
                              34,
                              wide ? 36 : 22,
                              0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _PopularCategorySection(
                                name: categoryName,
                                recipes:
                                    state.categoryRecipes[categoryName] ??
                                    const [],
                                loading: state.categoryLoading.contains(
                                  categoryName,
                                ),
                                error: state.categoryErrors[categoryName],
                                onRetry: () => context.read<RecipesBloc>().add(
                                  LoadRecipesByCategory(categoryName),
                                ),
                                onSeeAll: () {
                                  setState(
                                    () => _selectedCategory = categoryName,
                                  );
                                  context.read<RecipesBloc>().add(
                                    LoadRecipesByCategory(categoryName),
                                  );
                                },
                                onOpenRecipe: (recipe) =>
                                    _openRecipe(context, recipe),
                              ),
                            ),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 46)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  void _openRecipe(BuildContext context, RecipeEntity recipe) =>
      Navigator.pushNamed(context, '/detail_screen', arguments: recipe.id);
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({
    required this.searching,
    required this.controller,
    required this.onChanged,
  });
  final bool searching;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Qué quieres\ncocinar hoy?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Descubre recetas deliciosas para cada momento.',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: AppPalette.muted),
                ),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width > 430)
            Container(
              width: 96,
              height: 96,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: AppPalette.primarySoft,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.ramen_dining_rounded,
                size: 52,
                color: AppPalette.primary,
              ),
            ),
        ],
      ),
      const SizedBox(height: 21),
      Container(
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: AppPalette.ink.withValues(alpha: .055),
              blurRadius: 22,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Busca una receta...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: searching
                ? IconButton(
                    tooltip: 'Limpiar búsqueda',
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(19),
              borderSide: const BorderSide(
                color: AppPalette.primary,
                width: 1.4,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _HorizontalRecipes extends StatelessWidget {
  const _HorizontalRecipes({
    required this.recipes,
    required this.loading,
    required this.onOpenRecipe,
    required this.emptyLabel,
  });
  final List<RecipeEntity> recipes;
  final bool loading;
  final ValueChanged<RecipeEntity> onOpenRecipe;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (loading && recipes.isEmpty) return const _HorizontalSkeletons();
    if (recipes.isEmpty) {
      return Text(emptyLabel, style: Theme.of(context).textTheme.bodyMedium);
    }
    return SizedBox(
      height: 264,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recipes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 13),
        itemBuilder: (context, index) => RecipeHorizontalCard(
          recipe: recipes[index],
          onTap: () => onOpenRecipe(recipes[index]),
        ),
      ),
    );
  }
}

class _HorizontalSkeletons extends StatelessWidget {
  const _HorizontalSkeletons();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 264,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(width: 13),
      itemBuilder: (_, _) => const RecipeCardSkeleton(),
    ),
  );
}

class _FeaturedSkeletons extends StatelessWidget {
  const _FeaturedSkeletons();

  @override
  Widget build(BuildContext context) => const _HorizontalSkeletons();
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.query,
    required this.recipes,
    required this.loading,
    required this.failed,
    required this.onClear,
    required this.onRetry,
    required this.onOpenRecipe,
  });
  final String query;
  final List<RecipeEntity> recipes;
  final bool loading;
  final bool failed;
  final VoidCallback onClear;
  final VoidCallback onRetry;
  final ValueChanged<RecipeEntity> onOpenRecipe;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeader(
        title: 'Resultados',
        subtitle: 'Para “$query”',
        actionLabel: 'Limpiar',
        onAction: onClear,
      ),
      const SizedBox(height: 14),
      if (loading && recipes.isEmpty)
        const _HorizontalSkeletons()
      else if (failed && recipes.isEmpty)
        _InlineNotice(
          icon: Icons.wifi_off_rounded,
          message: 'No pudimos completar la búsqueda.',
          actionLabel: 'Reintentar',
          action: onRetry,
        )
      else if (recipes.isEmpty)
        _InlineNotice(
          icon: Icons.search_off_rounded,
          message:
              'No encontramos recetas. Prueba con otro ingrediente o plato.',
          actionLabel: 'Volver a explorar',
          action: onClear,
        )
      else
        _HorizontalRecipes(
          recipes: recipes,
          loading: false,
          onOpenRecipe: onOpenRecipe,
          emptyLabel: '',
        ),
    ],
  );
}

class _CategorySelection extends StatelessWidget {
  const _CategorySelection({
    required this.name,
    required this.recipes,
    required this.loading,
    required this.error,
    required this.onClose,
    required this.onRetry,
    required this.onOpenRecipe,
  });
  final String name;
  final List<RecipeEntity> recipes;
  final bool loading;
  final String? error;
  final VoidCallback onClose;
  final VoidCallback onRetry;
  final ValueChanged<RecipeEntity> onOpenRecipe;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeader(
        title: name,
        subtitle: 'Recetas de esta categoría',
        actionLabel: 'Cerrar',
        onAction: onClose,
      ),
      const SizedBox(height: 13),
      if (loading && recipes.isEmpty)
        const _HorizontalSkeletons()
      else if (error != null)
        _InlineNotice(
          icon: Icons.cloud_off_outlined,
          message: 'No pudimos cargar $name.',
          actionLabel: 'Reintentar',
          action: onRetry,
        )
      else if (recipes.isEmpty)
        const Text('No hay recetas disponibles en esta categoría.')
      else
        _HorizontalRecipes(
          recipes: recipes.take(5).toList(),
          loading: false,
          onOpenRecipe: onOpenRecipe,
          emptyLabel: '',
        ),
    ],
  );
}

class _PopularCategorySection extends StatelessWidget {
  const _PopularCategorySection({
    required this.name,
    required this.recipes,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.onSeeAll,
    required this.onOpenRecipe,
  });
  final String name;
  final List<RecipeEntity> recipes;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onSeeAll;
  final ValueChanged<RecipeEntity> onOpenRecipe;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeader(
        title: name,
        subtitle: 'Una selección para probar',
        actionLabel: 'Ver todas',
        onAction: onSeeAll,
      ),
      const SizedBox(height: 13),
      if (loading && recipes.isEmpty)
        const _HorizontalSkeletons()
      else if (error != null)
        _InlineNotice(
          icon: Icons.cloud_off_outlined,
          message: 'No pudimos cargar estas recetas.',
          actionLabel: 'Reintentar',
          action: onRetry,
        )
      else
        _HorizontalRecipes(
          recipes: recipes.take(5).toList(),
          loading: false,
          onOpenRecipe: onOpenRecipe,
          emptyLabel: 'No hay recetas disponibles.',
        ),
    ],
  );
}

class _CategoryError extends StatelessWidget {
  const _CategoryError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onRetry,
    icon: const Icon(Icons.refresh),
    label: const Text('No cargaron las categorías. Reintentar'),
  );
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.action,
  });
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: AppPalette.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppPalette.border),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppPalette.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ),
        TextButton(onPressed: action, child: Text(actionLabel)),
      ],
    ),
  );
}
