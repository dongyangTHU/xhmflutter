// lib/models/portrait_entity.dart

// 用于承载从API获取的“历史记录”数据
class PortraitEntity {
  final int id;
  final String imgUrl; // 这是我们需要展示的图片URL

  PortraitEntity({
    this.id = 0,
    this.imgUrl = '',
  });

  // 从JSON数据创建PortraitEntity实例的工厂构造函数
  factory PortraitEntity.fromJson(Map<String, dynamic> json) {
    return PortraitEntity(
      id: json['id'] ?? 0,
      imgUrl: json['imgUrl'] ?? '',
    );
  }
}
