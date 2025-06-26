// lib/models/category_entity.dart

class CategoryEntity {
  final int categoryId;
  final String categoryName;
  // 可以根据需要添加其他字段，如icon

  CategoryEntity({
    required this.categoryId,
    required this.categoryName,
  });

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '未知分类',
    );
  }
}
