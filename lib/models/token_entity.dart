// lib/models/token_entity.dart

// 用于承载登录接口返回的数据
class TokenEntity {
  final String token;

  TokenEntity({this.token = ''});

  factory TokenEntity.fromJson(Map<String, dynamic> json) {
    return TokenEntity(
      token: json['token'] ?? '',
    );
  }
}
