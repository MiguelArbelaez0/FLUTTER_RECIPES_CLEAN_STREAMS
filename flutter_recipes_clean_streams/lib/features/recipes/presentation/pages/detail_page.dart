import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection/injection_container.dart';
import '../../domain/entities/recipe_entity.dart';
import '../bloc/recipes_bloc.dart';
import '../bloc/recipes_event.dart';
import '../bloc/recipes_state.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.recipeId});

  final String recipeId;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<RecipesBloc>()..add(LoadRecipeDetail(widget.recipeId)),
    child: Scaffold(
      body: BlocBuilder<RecipesBloc, RecipesState>(
        builder: (context, state) {
          if (state.detailStatus == RecipeDetailStatus.loading ||
              state.detailStatus == RecipeDetailStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.detailStatus == RecipeDetailStatus.failure) {
            return _DetailError(
              message: state.errorMessage ?? 'No pudimos abrir esta receta.',
              retry: () => context.read<RecipesBloc>().add(
                LoadRecipeDetail(widget.recipeId),
              ),
            );
          }
          final recipe = state.selectedRecipe;
          if (recipe == null) return const SizedBox.shrink();
          return _RecipeDetails(
            recipe: recipe,
            saved: _saved,
            onSave: () => setState(() => _saved = !_saved),
          );
        },
      ),
    ),
  );
}

class _RecipeDetails extends StatelessWidget {
  const _RecipeDetails({
    required this.recipe,
    required this.saved,
    required this.onSave,
  });

  final RecipeEntity recipe;
  final bool saved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverAppBar(
        expandedHeight: 340,
        pinned: true,
        stretch: true,
        backgroundColor: AppPalette.background,
        leading: Padding(
          padding: const EdgeInsets.all(7),
          child: _RoundAction(
            icon: Icons.arrow_back,
            label: 'Volver',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _RoundAction(
              icon: saved ? Icons.favorite : Icons.favorite_border,
              label: saved ? 'Quitar de favoritos' : 'Guardar receta',
              onPressed: onSave,
              color: saved ? AppPalette.primary : AppPalette.ink,
            ),
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'recipe-${recipe.id}',
                child: recipe.imageUrl == null
                    ? const ColoredBox(color: AppPalette.primarySoft)
                    : Image.network(
                        recipe.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const ColoredBox(color: AppPalette.primarySoft),
                      ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black38,
                      Colors.transparent,
                      Colors.black54,
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 27,
                child: Text(
                  recipe.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    shadows: const [
                      Shadow(blurRadius: 8, color: Colors.black45),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 21, 22, 36),
        sliver: SliverList.list(
          children: [
            Wrap(
              spacing: 9,
              runSpacing: 8,
              children: [
                if (recipe.category?.isNotEmpty == true)
                  _InfoChip(icon: Icons.restaurant, text: recipe.category!),
                if (recipe.area?.isNotEmpty == true)
                  _InfoChip(icon: Icons.public, text: recipe.area!),
              ],
            ),
            const SizedBox(height: 28),
            _SectionHeading(
              title: 'Ingredientes',
              trailing: '${recipe.ingredients.length}',
            ),
            const SizedBox(height: 10),
            if (recipe.ingredients.isEmpty)
              const Text('No hay ingredientes disponibles para esta receta.')
            else
              ...recipe.ingredients.map(
                (ingredient) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.surface,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 19,
                          color: AppPalette.secondary,
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            ingredient.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (ingredient.measure?.isNotEmpty == true)
                          Text(
                            ingredient.measure!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 27),
            const _SectionHeading(title: 'Preparación'),
            const SizedBox(height: 12),
            Text(
              recipe.instructions?.trim().isNotEmpty == true
                  ? recipe.instructions!.trim()
                  : 'No hay instrucciones disponibles.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    ],
  );
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color = AppPalette.ink,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: 0.94),
    shape: const CircleBorder(),
    child: IconButton(
      tooltip: label,
      onPressed: onPressed,
      icon: Icon(icon, color: color),
    ),
  );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 16, color: AppPalette.secondary),
    label: Text(text),
    backgroundColor: AppPalette.surface,
    side: const BorderSide(color: AppPalette.border),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      if (trailing != null) ...[
        const SizedBox(width: 9),
        Text(trailing!, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ],
  );
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.retry});
  final String message;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 42, color: AppPalette.primary),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: retry, child: const Text('Reintentar')),
        ],
      ),
    ),
  );
}
