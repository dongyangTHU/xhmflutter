// lib/viewmodels/auth_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/token_entity.dart';
import 'user_viewmodel.dart';

enum AuthStatus { initializing, authenticated, unauthenticated }

class AuthViewModel extends ChangeNotifier {
  late final Dio _dio;
  // AuthViewModel现在持有一个UserViewModel的实例
  final UserViewModel _userViewModel;

  AuthStatus _authStatus = AuthStatus.initializing;
  bool _isLoading = false;
  String? _error;
  String? _token;

  AuthStatus get authStatus => _authStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;

  // 修改构造函数以接收注入的UserViewModel
  AuthViewModel(this._userViewModel) {
    _dio = Dio();
    if (kDebugMode) {
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
  }

  // 用于App启动时，验证本地Token的有效性
  Future<void> validateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');

    if (storedToken == null || storedToken.isEmpty) {
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      _token = storedToken;
      _userViewModel.updateToken(storedToken);
      await _userViewModel.fetchUserInfo();

      if (_userViewModel.error == null) {
        _authStatus = AuthStatus.authenticated;
      } else {
        await _logoutInternal(); // 验证失败，静默登出
        _authStatus = AuthStatus.unauthenticated;
      }
    } catch (e) {
      await _logoutInternal();
      _authStatus = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  // 登录成功后的逻辑
  Future<void> _loginSuccess(String newToken) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', newToken);
      _token = newToken;
      _userViewModel.updateToken(newToken);
      await _userViewModel.fetchUserInfo();
      if (_userViewModel.error == null) {
        _authStatus = AuthStatus.authenticated;
      } else {
        _error = '登录成功，但获取用户信息失败: ${_userViewModel.error}';
        _authStatus = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _error = '保存 Token 或获取用户信息时出错: $e';
      _authStatus = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 登出
  Future<void> logout() async {
    await _logoutInternal();
    notifyListeners();
  }

  // 内部登出方法，不通知监听器，供内部调用
  Future<void> _logoutInternal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    _userViewModel.clearUser();
  }

  // 使用短信登录
  Future<void> loginWithSms(String phone, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _dio.post(
        'https://www.xiaohongmaoai.com/app/login/smsLogin',
        data: {'phoneNumber': phone, 'smsCode': code},
      );
      final apiResponse = ApiResponse.fromJson(
          response.data, (json) => TokenEntity.fromJson(json));
      if (apiResponse.isSuccess &&
          apiResponse.data != null &&
          apiResponse.data!.token.isNotEmpty) {
        await _loginSuccess(apiResponse.data!.token);
      } else {
        _error = "登录失败: ${apiResponse.msg}";
        _authStatus = AuthStatus.unauthenticated;
        notifyListeners();
      }
    } on DioException catch (e) {
      _error = '网络请求失败: ${e.message}';
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _error = '发生未知错误，请稍后重试';
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  // 发送短信验证码
  Future<bool> sendSmsCode(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _dio.post(
        'https://www.xiaohongmaoai.com/app/sendCode',
        data: {'phoneNumber': phone},
      );

      if (response.data is! Map<String, dynamic>) {
        _error = "发送失败：服务器响应格式错误";
        notifyListeners();
        return false;
      }

      final apiResponse = ApiResponse.fromJson(response.data, null);
      if (apiResponse.isSuccess) {
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = "发送失败: ${apiResponse.msg}";
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _error = "网络请求失败: ${e.message}";
      notifyListeners();
      return false;
    } catch (e) {
      _error = "发生未知错误，请稍后重试";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // 清除错误信息
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // 测试登录
  Future<void> loginForTest() async {
    const testToken =
        "eyJhbGciOiJIUzUxMiJ9.eyJhcHBfbG9naW5fdXNlcl9rZXkiOiI5OTA1Zjk1ZS0wNTQ2LTQxZDUtOGNiYi0xYmIwZmM2ZTNjOTYifQ.b425YQcnKoZQaktUqK8k4WqDMzFYaOiGFFbJWrAiDALSEi59yoNdRqWhUZzcJpanKmyyilFcytrl1w9sglIxyw";
    await _loginSuccess(testToken);
  }
}
