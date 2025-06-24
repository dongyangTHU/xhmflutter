// lib/models/user_entity.dart

// 这是一个简化的用户数据模型，仅包含当前集成所需字段
// V2.0 项目可以根据需要扩展此模型
class UserEntity {
  final String userId;
  final String nickName;
  final String avatar;
  final String balance; // 冻干余额
  final int remainingDays; // 会员剩余天数

  UserEntity({
    this.userId = '',
    this.nickName = '',
    this.avatar = '',
    this.balance = '0',
    this.remainingDays = 0,
  });

  // 从 JSON 数据创建 UserEntity 实例的工厂构造函数
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      userId: json['userId'] ?? '',
      nickName: json['nickName'] ?? '游客', // 提供默认值
      avatar: json['avatar'] ?? '',
      balance: json['balance']?.toString() ?? '0', // 确保是字符串
      remainingDays: json['remainingDays'] ?? 0,
    );
  }
}
