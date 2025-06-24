// lib/viewmodels/user_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart'; // 1. 导入包
import '../models/api_response.dart';
import '../models/user_entity.dart';

class UserViewModel extends ChangeNotifier {
  late final Dio _dio; // 将 Dio 实例设为 final
  UserEntity? _userInfo;
  bool _isLoading = false;
  String? _error;
  String _token = '';

  UserEntity? get userInfo => _userInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserViewModel() {
    // 2. 在构造函数中初始化 Dio 和拦截器
    _dio = Dio();
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));
  }

  void clearUser() {
    _userInfo = null;
    _token = '';
    notifyListeners();
  }

  void updateToken(String newToken) {
    _token = newToken;
  }

  Future<void> fetchUserInfo() async {
    if (_token.isEmpty) {
      _error = "用户未登录";
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get(
        'https://www.xiaohongmaoai.com/app/user/getInfo',
        options: Options(headers: {'Authorization': _token}),
      );

      final apiResponse = ApiResponse.fromJson(
          response.data, (json) => UserEntity.fromJson(json));
      if (apiResponse.isSuccess && apiResponse.data != null) {
        _userInfo = apiResponse.data;
        _error = null;
      } else {
        _error = "获取用户信息失败: ${apiResponse.msg}";
        _userInfo = null;
      }
    } on DioException catch (e) {
      _error = "网络请求异常: ${e.message}";
      _userInfo = null;
    } catch (e) {
      _error = "发生未知错误: $e";
      _userInfo = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
