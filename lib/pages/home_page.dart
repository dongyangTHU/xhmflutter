// lib/pages/home_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/app_top_bar.dart';
import '../models/api_response.dart';
import '../models/banner_entity.dart';
import '../models/portrait_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _bannerPageController;
  int _currentPage = 0;
  Timer? _bannerTimer;
  final Dio _dio = Dio();

  // --- State管理的数据 ---
  bool _isLoading = true;
  String? _error;
  List<BannerEntity> _banners = [];
  List<PortraitEntity> _historyPortraits = [];

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController(initialPage: 0);

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.token == null || authViewModel.token!.isEmpty) {
      if (mounted) {
        setState(() {
          _error = "用户未登录";
          _isLoading = false;
        });
      }
      return;
    }

    try {
      // 1. 调用Banner接口
      final bannerResponse = await _dio.get(
        'https://www.xiaohongmaoai.com/app/banner/list',
        queryParameters: {'bannerPlace': '4'},
        options: Options(headers: {'Authorization': authViewModel.token}),
      );
      final bannerApiResponse = ApiResponse.fromJson(
          bannerResponse.data,
          (json) =>
              (json as List).map((i) => BannerEntity.fromJson(i)).toList());
      if (bannerApiResponse.isSuccess && bannerApiResponse.data != null) {
        if (mounted) setState(() => _banners = bannerApiResponse.data!);
      } else {
        _error = "获取Banner失败: ${bannerApiResponse.msg}";
      }

      // 2. 调用v1.0版本的历史记录接口
      final historyResponse = await _dio.post(
        'https://www.xiaohongmaoai.com/app/petExhibition/getExhibitionList',
        data: {'currentPage': 1, 'pageSize': 100, 'type': '2'},
        options: Options(headers: {'Authorization': authViewModel.token}),
      );

      final historyApiResponse = ApiResponse.fromJson(
          historyResponse.data,
          (json) =>
              (json as List).map((i) => PortraitEntity.fromJson(i)).toList());

      if (historyApiResponse.isSuccess && historyApiResponse.data != null) {
        // --- 核心修改：只取返回数据的前6张图片 ---
        // 使用 .take(6) 可以安全地截取列表，如果列表长度小于6，则会取所有元素
        final limitedHistory = historyApiResponse.data!.take(6).toList();
        if (mounted) setState(() => _historyPortraits = limitedHistory);
      } else {
        _error = _error ?? "获取相册记录失败: ${historyApiResponse.msg}";
      }
    } catch (e) {
      if (mounted) setState(() => _error = "数据加载时发生网络异常: $e");
      debugPrint('数据获取失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (_banners.isNotEmpty) {
          _startBannerTimer();
        }
      }
    }
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    if (_banners.isEmpty) return;
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerPageController.hasClients) {
        int nextPage =
            (_bannerPageController.page!.round() + 1) % _banners.length;
        _bannerPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // ===================================================================
  // --- 核心修改 1: 新增 Banner 点击事件处理方法 ---
  // ===================================================================
  /// @description 处理Banner点击事件
  /// @param banner 被点击的Banner实体对象
  void _onBannerTapped(BannerEntity banner) {
    debugPrint(
        "Banner Tapped: title=${banner.title}, type=${banner.bannerType}");

    // 根据 bannerType 执行不同的跳转逻辑
    switch (banner.bannerType) {
      case '2':
        // bannerType为'2'，跳转到创作/商店页面
        context.push('/creation-store');
        break;
      case '3':
        // bannerType为'3'，跳转到会员充值页面
        context.push('/membership-recharge');
        break;
      default:
        // 对于其他未知的 bannerType，可以不执行任何操作，或打印日志
        debugPrint("未知的 Banner 类型: ${banner.bannerType}");
        break;
    }
  }
  // ===================================================================

  @override
  void dispose() {
    _bannerPageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/cat1.jpg', fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(color: Colors.black.withOpacity(0.2)),
        ),
        SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const AppTopBar(),
                  const SizedBox(height: 20),
                  _buildMenuButtons(context),
                  const SizedBox(height: 20),
                  _buildBannerSection(),
                  const SizedBox(height: 24),
                  _buildAlbumSection(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerSection() {
    if (_isLoading && _banners.isEmpty) {
      return const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator(color: Colors.white)));
    }
    if (_error != null && _banners.isEmpty) {
      return SizedBox(
          height: 180,
          child: Center(
              child: Text(_error!,
                  style: const TextStyle(color: Colors.white70))));
    }
    if (_banners.isEmpty) {
      return const SizedBox(
          height: 180,
          child: Center(
              child: Text('暂无推荐内容', style: TextStyle(color: Colors.white70))));
    }
    return _buildBannerUI();
  }

  Widget _buildAlbumSection() {
    return Column(
      children: [
        const Text('相册',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('拍摄完的AI作品显示在此',
            style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 20),
        if (!_isLoading)
          _historyPortraits.isEmpty
              ? _buildEmptyAlbumState(context)
              : _buildImageGrid(),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildImageGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _historyPortraits.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (context, index) {
          final portrait = _historyPortraits[index];
          return Hero(
            tag: portrait.imgUrl,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: () {
                  context.push('/photo-view', extra: portrait.imgUrl);
                },
                child: CachedNetworkImage(
                  imageUrl: portrait.imgUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.black.withOpacity(0.2)),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, color: Colors.white70),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyAlbumState(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/creation-store');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 150,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.camera_enhance_outlined,
                  color: Colors.white70, size: 40),
              SizedBox(height: 12),
              Text(
                '点击制作你的第一张AI写真',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerUI() {
    // 这部分移除了 currentPage 变量，因为 initState 中已经有了 _currentPage
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _bannerPageController,
            itemCount: _banners.length,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) {
              final banner = _banners[index];
              // ===================================================================
              // --- 核心修改 2: 使用 GestureDetector 包裹 Banner 项 ---
              // ===================================================================
              return GestureDetector(
                // 点击时调用我们新增的处理方法
                onTap: () => _onBannerTapped(banner),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: banner.imgUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.black.withOpacity(0.2)),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: Colors.white70),
                    ),
                  ),
                ),
              );
              // ===================================================================
            },
          ),
          Positioned(
            bottom: 10.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _banners.length,
                (index) => _buildDotIndicator(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: _currentPage == index ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.white54,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => context.push('/creation-store'),
            child: _buildMenuButton(Icons.add_circle, '开始创作'),
          ),
          _buildMenuButton(Icons.pets, '我的宠物'),
          _buildMenuButton(Icons.photo_library, '每日写真'),
          _buildMenuButton(Icons.back_hand, '偷只小猫'),
        ],
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
