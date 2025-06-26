// lib/models/goods_entity.dart

class GoodsEntity {
  final String goodsId;
  final String goodsName;
  final String coverUrl;
  final String useNum;
  final int price;

  GoodsEntity({
    required this.goodsId,
    required this.goodsName,
    required this.coverUrl,
    required this.useNum,
    required this.price,
  });

  factory GoodsEntity.fromJson(Map<String, dynamic> json) {
    return GoodsEntity(
      goodsId: json['goodsId'] ?? '',
      goodsName: json['goodsName'] ?? '未知套系',
      coverUrl: json['coverUrl'] ?? '',
      // useNum字段在v1.0中是字符串，我们保持一致
      useNum: json['useNum']?.toString() ?? '0',
      price: json['price'] ?? 0,
    );
  }
}
