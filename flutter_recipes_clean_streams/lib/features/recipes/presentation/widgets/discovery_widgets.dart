import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/recipe_entity.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 47,
        height: 47,
        decoration: BoxDecoration(
          color: AppPalette.primary,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: AppPalette.primary.withValues(alpha: .2),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sazón', style: Theme.of(context).textTheme.titleLarge),
          Text(
            'RECETAS PARA DISFRUTAR',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: AppPalette.muted, letterSpacing: 1.1),
          ),
        ],
      ),
      const Spacer(),
      Container(
        decoration: const BoxDecoration(
          color: AppPalette.surface,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          tooltip: 'Tu perfil',
          onPressed: () {},
          icon: const Icon(Icons.person_outline_rounded),
        ),
      ),
    ],
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
      if (actionLabel != null)
        TextButton(onPressed: onAction, child: Text(actionLabel!)),
    ],
  );
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });
  final CategoryEntity category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 112,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: selected ? AppPalette.primarySoft : AppPalette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppPalette.primary.withValues(alpha: .5)
                : AppPalette.border,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox.expand(
                  child: category.imageUrl == null
                      ? const ColoredBox(
                          color: AppPalette.primarySoft,
                          child: Icon(
                            Icons.restaurant,
                            color: AppPalette.primary,
                          ),
                        )
                      : Image.network(
                          category.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                              ? child
                              : const _ImagePlaceholder(icon: Icons.restaurant),
                          errorBuilder: (_, _, _) =>
                              const _ImagePlaceholder(icon: Icons.restaurant),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );
}

class RecipeHorizontalCard extends StatefulWidget {
  const RecipeHorizontalCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.categoryLabel,
  });
  final RecipeEntity recipe;
  final VoidCallback onTap;
  final String? categoryLabel;

  @override
  State<RecipeHorizontalCard> createState() => _RecipeHorizontalCardState();
}

class _RecipeHorizontalCardState extends State<RecipeHorizontalCard> {
  bool _favorite = false;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return SizedBox(
      width: 230,
      child: Material(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    recipe.imageUrl == null
                        ? const _ImagePlaceholder(icon: Icons.restaurant_menu)
                        : Image.network(
                            recipe.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                ? child
                                : const _ImagePlaceholder(
                                    icon: Icons.restaurant_menu,
                                  ),
                            errorBuilder: (_, _, _) => const _ImagePlaceholder(
                              icon: Icons.restaurant_menu,
                            ),
                          ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Material(
                        color: Colors.white.withValues(alpha: .95),
                        shape: const CircleBorder(),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: _favorite
                              ? 'Quitar de favoritos'
                              : 'Guardar receta',
                          onPressed: () =>
                              setState(() => _favorite = !_favorite),
                          icon: Icon(
                            _favorite ? Icons.favorite : Icons.favorite_border,
                            color: _favorite
                                ? AppPalette.primary
                                : AppPalette.ink,
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.categoryLabel ??
                            recipe.category ??
                            'PARA DISFRUTAR',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppPalette.secondary,
                          fontSize: 10,
                          letterSpacing: .9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        recipe.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(height: 1.2),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.public,
                            size: 14,
                            color: AppPalette.muted,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              recipe.area ?? 'Cocina internacional',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 17,
                            color: AppPalette.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeCardSkeleton extends StatelessWidget {
  const RecipeCardSkeleton({super.key, this.width = 230});
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: 262,
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(flex: 6, child: Container(color: AppPalette.border)),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 9,
                    width: 70,
                    decoration: BoxDecoration(
                      color: AppPalette.border,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 11),
                  Container(
                    height: 13,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppPalette.border,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    height: 13,
                    width: 105,
                    decoration: BoxDecoration(
                      color: AppPalette.border,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class CategoryCardSkeleton extends StatelessWidget {
  const CategoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 112,
    height: 132,
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: AppPalette.surface,
      border: Border.all(color: AppPalette.border),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppPalette.border,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 10,
          width: 60,
          decoration: BoxDecoration(
            color: AppPalette.border,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    ),
  );
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppPalette.primarySoft,
    child: Center(
      child: Icon(
        icon,
        size: 34,
        color: AppPalette.primary.withValues(alpha: .8),
      ),
    ),
  );
}
