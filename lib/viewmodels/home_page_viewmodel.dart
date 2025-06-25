// lib/viewmodels/home_page_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/banner_entity.dart';
import 'auth_viewmodel.dart'; // 需要认证信息来获取token

class HomePageViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel; // 依赖AuthViewModel获取token
  late final Dio _dio;

  // -- 状态定义 --
  List<BannerEntity> _banners = []; // Banner数据列表
  bool _isLoading = false; // 是否正在加载
  String? _error; // 错误信息

  // -- Getters，供UI访问 --
  List<BannerEntity> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // -- 构造函数 --
  HomePageViewModel(this._authViewModel) {
    // 初始化Dio实例，可以添加日志拦截器等通用配置
    _dio = Dio();
  }

  // -- 核心方法：获取Banner数据 --
  Future<void> fetchBanners() async {
    // 如果没有token，则不执行操作
    if (_authViewModel.token == null || _authViewModel.token!.isEmpty) {
      _error = "用户未登录，无法加载数据";
      notifyListeners();
      return;
    }

    _isLoading = true; // 开始加载，通知UI更新
    _error = null;
    notifyListeners();

    try {
      // 发起网络请求，获取banner列表
      // 根据v1.0代码分析，bannerPlace参数为'4'
      final response = await _dio.get(
        'https://www.xiaohongmaoai.com/app/banner/getBanners',
        queryParameters: {'bannerPlace': '4'},
        options: Options(
          headers: {'Authorization': _authViewModel.token}, // 在请求头中携带认证token
        ),
      );

      // 使用通用的ApiResponse模型进行解析
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) =>
            (json as List).map((item) => BannerEntity.fromJson(item)).toList(),
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        _banners = apiResponse.data!; // 请求成功，更新banner列表
      } else {
        _error = "获取Banner失败: ${apiResponse.msg}"; // 请求失败，记录错误信息
        _banners = []; // 清空列表
      }
    } on DioException catch (e) {
      _error = "网络请求异常: ${e.message}"; // 网络异常
      _banners = [];
    } catch (e) {
      _error = "发生未知错误: $e"; // 其他未知错误
      _banners = [];
    } finally {
      _isLoading = false; // 加载结束
      notifyListeners(); // 最终通知UI更新
    }
  }
}
