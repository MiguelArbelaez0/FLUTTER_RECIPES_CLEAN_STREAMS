import '../../domain/entities/recipe_entity.dart';
import '../../../../core/utils/normalized_text.dart';

class IngredientModel extends IngredientEntity {
  const IngredientModel({required super.name, super.measure});

  static IngredientModel? fromMealJson(Map<String, dynamic> json, int index) {
    final name = normalizedText(json['strIngredient$index']);
    if (name == null) return null;
    final measure = normalizedText(json['strMeasure$index']);
    return IngredientModel(name: name, measure: measure);
  }

  Map<String, dynamic> toMealJson(int index) => {
    'strIngredient$index': name,
    'strMeasure$index': measure ?? '',
  };
}
