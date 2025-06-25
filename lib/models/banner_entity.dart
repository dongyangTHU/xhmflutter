// lib/models/banner_entity.dart

// 用于承载从API获取的Banner数据
class BannerEntity {
  final String imgUrl; // Banner的图片链接
  final String title; // Banner的标题
  final String content; // 内容，可能是商品ID或其他标识
  final String bannerType; // Banner类型，用于后续的点击跳转逻辑

  BannerEntity({
    this.imgUrl = '',
    this.title = '',
    this.content = '',
    this.bannerType = '',
  });

  // 从JSON数据创建BannerEntity实例的工厂构造函数
  factory BannerEntity.fromJson(Map<String, dynamic> json) {
    return BannerEntity(
      imgUrl: json['imgUrl'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      bannerType: json['bannerType'] ?? '',
    );
  }
}
