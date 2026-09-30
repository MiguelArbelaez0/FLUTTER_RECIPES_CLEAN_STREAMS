import 'package:equatable/equatable.dart';

class RecipeEntity extends Equatable {
  const RecipeEntity({
    required this.id,
    required this.name,
    this.category,
    this.area,
    this.instructions,
    this.imageUrl,
    this.ingredients = const [],
  });

  final String id;
  final String name;
  final String? category;
  final String? area;
  final String? instructions;
  final String? imageUrl;
  final List<IngredientEntity> ingredients;

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    area,
    instructions,
    imageUrl,
    ingredients,
  ];
}

class IngredientEntity extends Equatable {
  const IngredientEntity({required this.name, this.measure});

  final String name;
  final String? measure;

  @override
  List<Object?> get props => [name, measure];
}
