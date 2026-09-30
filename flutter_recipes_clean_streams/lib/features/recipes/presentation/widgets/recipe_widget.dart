import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/recipe_entity.dart';

class RecipeWidget extends StatefulWidget {
  const RecipeWidget({super.key, required this.recipe, required this.tap});

  final RecipeEntity recipe;
  final VoidCallback tap;

  @override
  State<RecipeWidget> createState() => _RecipeWidgetState();
}

class _RecipeWidgetState extends State<RecipeWidget> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return Material(
      color: AppPalette.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.tap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'recipe-${recipe.id}',
                    child: recipe.imageUrl == null
                        ? _imageFallback()
                        : Image.network(
                            recipe.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _imageFallback(),
                          ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.94),
                      shape: const CircleBorder(),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: _saved
                            ? 'Quitar de favoritos'
                            : 'Guardar receta',
                        onPressed: () => setState(() => _saved = !_saved),
                        icon: Icon(
                          _saved ? Icons.favorite : Icons.favorite_border,
                          color: _saved ? AppPalette.primary : AppPalette.ink,
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
                padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.category?.toUpperCase() ?? 'RECETA',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppPalette.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
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
                          Icons.arrow_forward,
                          size: 16,
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
    );
  }

  Widget _imageFallback() => ColoredBox(
    color: AppPalette.primarySoft,
    child: const Center(
      child: Icon(Icons.restaurant, size: 38, color: AppPalette.primary),
    ),
  );
}
