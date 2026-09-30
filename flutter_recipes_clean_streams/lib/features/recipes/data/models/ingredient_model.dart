import '../../../../core/utils/normalized_text.dart';

class IngredientModel {
  const IngredientModel({required this.name, this.measure});

  final String name;
  final String? measure;

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
