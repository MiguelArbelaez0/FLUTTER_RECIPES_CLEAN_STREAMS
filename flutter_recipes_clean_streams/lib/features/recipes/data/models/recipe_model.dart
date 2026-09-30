import '../../domain/entities/recipe_entity.dart';
import '../../../../core/utils/normalized_text.dart';
import 'ingredient_model.dart';

class RecipeModel {
  const RecipeModel({
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
  final List<IngredientModel> ingredients;

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final id = normalizedText(json['idMeal']);
    final name = normalizedText(json['strMeal']);
    if (id == null || id.isEmpty || name == null || name.isEmpty) {
      throw const FormatException('Meal is missing its id or name.');
    }

    return RecipeModel(
      id: id,
      name: name,
      category: normalizedText(json['strCategory']),
      area: normalizedText(json['strArea']),
      instructions: normalizedText(json['strInstructions']),
      imageUrl: normalizedText(json['strMealThumb']),
      ingredients: [
        for (var index = 1; index <= 20; index++)
          ?IngredientModel.fromMealJson(json, index),
      ],
    );
  }

  RecipeEntity toEntity() => RecipeEntity(
    id: id,
    name: name,
    category: category,
    area: area,
    instructions: instructions,
    imageUrl: imageUrl,
    ingredients: [
      for (final ingredient in ingredients)
        IngredientEntity(name: ingredient.name, measure: ingredient.measure),
    ],
  );

  Map<String, dynamic> toJson() => {
    'idMeal': id,
    'strMeal': name,
    'strCategory': category,
    'strArea': area,
    'strInstructions': instructions,
    'strMealThumb': imageUrl,
    for (var index = 0; index < ingredients.length; index++)
      ...ingredients[index].toMealJson(index + 1),
    for (var index = ingredients.length + 1; index <= 20; index++) ...{
      'strIngredient$index': '',
      'strMeasure$index': '',
    },
  };
}
