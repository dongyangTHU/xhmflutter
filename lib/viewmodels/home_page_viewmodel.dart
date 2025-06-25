// lib/viewmodels/home_page_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/api_response.dart';
import '../models/banner_entity.dart';
import 'auth_viewmodel.dart';

class HomePageViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;
  late final Dio _dio;

  // --- 状态定义 ---
  // 只保留Banner相关的状态，因为UI上只显示Banner
  List<BannerEntity> _banners = [];
  bool _isLoading = true;
  String? _error;

  List<BannerEntity> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HomePageViewModel(this._authViewModel) {
    debugPrint("[HomePageViewModel] ViewModel 已创建并初始化。");
    _dio = Dio();
    _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90));

    fetchData();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (_authViewModel.token == null || _authViewModel.token!.isEmpty) {
      _error = "用户未登录";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // 1. 获取Banner数据 (这部分逻辑保持不变)
      final bannerResponse = await _dio.get(
        'https://www.xiaohongmaoai.com/app/banner/list',
        queryParameters: {'bannerPlace': '4'},
        options: Options(headers: {'Authorization': _authViewModel.token}),
      );
      final bannerApiResponse = ApiResponse.fromJson(
          bannerResponse.data,
          (json) =>
              (json as List).map((i) => BannerEntity.fromJson(i)).toList());
      if (bannerApiResponse.isSuccess && bannerApiResponse.data != null) {
        _banners = bannerApiResponse.data!;
      } else {
        _error = "获取Banner失败: ${bannerApiResponse.msg}";
      }

      // --- 核心修改: 在这里调用v1.0版本的历史记录接口，仅用于调试 ---
      debugPrint("[HomePageViewModel] Banner获取完毕，现在开始调用v1.0的历史记录接口...");

      final historyResponse = await _dio.post(
        // 使用v1.0的接口路径
        'https://www.xiaohongmaoai.com/app/petExhibition/getExhibitionList',
        // 使用v1.0的请求参数
        data: {
          'currentPage': 1,
          'pageSize': 10, // 先获取少量数据用于测试
          'type': '2', // '2' 代表历史记录
        },
        options: Options(headers: {'Authorization': _authViewModel.token}),
      );

      // 2. 拦截并打印历史记录返回的原始JSON数据
      debugPrint("================ v1.0历史记录API返回的JSON ================");
      debugPrint(historyResponse.data.toString());
      debugPrint("==========================================================");
    } catch (e) {
      _error = "数据加载时发生网络异常: $e";
      debugPrint("[HomePageViewModel] 数据加载时发生错误: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
