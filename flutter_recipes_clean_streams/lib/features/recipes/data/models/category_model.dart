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

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['idCategory']?.toString() ?? json['strCategory']?.toString() ?? '',
    name: json['strCategory']?.toString() ?? '',
    description: json['strCategoryDescription']?.toString(),
    imageUrl: json['strCategoryThumb']?.toString(),
  );

  CategoryEntity toEntity() => CategoryEntity(
    id: id,
    name: name,
    description: description,
    imageUrl: imageUrl,
  );
}
