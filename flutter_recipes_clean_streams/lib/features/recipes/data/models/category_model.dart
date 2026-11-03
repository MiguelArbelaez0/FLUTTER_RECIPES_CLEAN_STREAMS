import '../../../../core/utils/normalized_text.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? description;
  final String? imageUrl;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final name = normalizedText(json['strCategory']);
    final id = normalizedText(json['idCategory']);
    if (id == null || name == null) {
      throw const FormatException('Category is missing its id or name.');
    }
    return CategoryModel(
      id: id,
      name: name,
      description: normalizedText(json['strCategoryDescription']),
      imageUrl: normalizedText(json['strCategoryThumb']),
    );
  }

  CategoryEntity toEntity() => CategoryEntity(
    id: id,
    name: name,
    description: description,
    imageUrl: imageUrl,
  );
}
