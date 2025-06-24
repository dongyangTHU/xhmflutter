// lib/viewmodels/auth_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/token_entity.dart';
import '../models/user_entity.dart';
import 'user_viewmodel.dart';

enum AuthStatus { initializing, authenticated, unauthenticated }

class AuthViewModel extends ChangeNotifier {
  late final Dio _dio;
  AuthStatus _authStatus = AuthStatus.initializing;
  bool _isLoading = false;
  String? _error;
  String? _token;

  AuthStatus get authStatus => _authStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;

  AuthViewModel() {
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
    _checkToken();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _authStatus = (_token != null && _token!.isNotEmpty)
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _loginSuccess(
      String newToken, UserViewModel userViewModel) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', newToken);
      _token = newToken;
      userViewModel.updateToken(newToken);
      await userViewModel.fetchUserInfo();
      if (userViewModel.error == null) {
        _authStatus = AuthStatus.authenticated;
      } else {
        _error = '登录成功，但获取用户信息失败: ${userViewModel.error}';
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

  Future<void> loginWithSms(
      String phone, String code, UserViewModel userViewModel) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _dio.post(
        'https://www.xiaohongmaoai.com/app/login/smsLogin',
        data: {'phoneNumber': phone, 'smsCode': code},
      );

      if (response.data is! Map<String, dynamic>) {
        _error = "登录失败：服务器响应格式错误";
        _authStatus = AuthStatus.unauthenticated;
      } else {
        final apiResponse = ApiResponse.fromJson(
            response.data, (json) => TokenEntity.fromJson(json));
        if (apiResponse.isSuccess &&
            apiResponse.data != null &&
            apiResponse.data!.token.isNotEmpty) {
          await _loginSuccess(apiResponse.data!.token, userViewModel);
        } else {
          _error = "登录失败: ${apiResponse.msg}";
          _authStatus = AuthStatus.unauthenticated;
        }
      }
    } on DioException catch (e) {
      _error = '网络请求失败: ${e.message}';
      _authStatus = AuthStatus.unauthenticated;
    } catch (e) {
      _error = '发生未知错误，请稍后重试';
      _authStatus = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
        return false;
      }

      final apiResponse = ApiResponse.fromJson(response.data, null);
      if (apiResponse.isSuccess) {
        _error = null;
        return true;
      } else {
        _error = "发送失败: ${apiResponse.msg}";
        return false;
      }
    } on DioException catch (e) {
      _error = "网络请求失败: ${e.message}";
      return false;
    } catch (e) {
      _error = "发生未知错误，请稍后重试";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 核心修改: 更新为新的测试 Token ---
  Future<void> loginForTest(UserViewModel userViewModel) async {
    // 使用您提供的新 token
    const testToken =
        "eyJhbGciOiJIUzUxMiJ9.eyJhcHBfbG9naW5fdXNlcl9rZXkiOiI5OTA1Zjk1ZS0wNTQ2LTQxZDUtOGNiYi0xYmIwZmM2ZTNjOTYifQ.b425YQcnKoZQaktUqK8k4WqDMzFYaOiGFFbJWrAiDALSEi59yoNdRqWhUZzcJpanKmyyilFcytrl1w9sglIxyw";
    await _loginSuccess(testToken, userViewModel);
  }

  Future<void> logout(UserViewModel userViewModel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    userViewModel.clearUser();
    _authStatus = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
