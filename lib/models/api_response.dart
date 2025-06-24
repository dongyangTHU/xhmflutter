// lib/models/api_response.dart

class ApiResponse<T> {
  final int code;
  final String msg;
  final T? data;

  ApiResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  bool get isSuccess => code == 0;

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic json)? fromJsonT) {
    return ApiResponse<T>(
      code: json['code'] ?? -1,
      msg: json['msg'] ?? '无错误信息',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}
