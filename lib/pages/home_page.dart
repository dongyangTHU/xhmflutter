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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _bannerPageController;
  int _currentPage = 0;
  Timer? _bannerTimer;
  List<String> _bannerImageUrls = [];
  bool _isBannerLoading = true;

  final Dio _dio = Dio();

  final List<String> _gridImagePaths = [
    'assets/images/cat5.jpg',
    'assets/images/cat6.jpg',
    'assets/images/cat7.jpg',
    'assets/images/cat8.jpg',
  ];

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

    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.token == null || authViewModel.token!.isEmpty) {
      if (mounted) setState(() => _isBannerLoading = false);
      return;
    }

    try {
      // --- 最终修正: 使用从api.dart文件中确认的正确URL ---
      final response = await _dio.get(
        'https://www.xiaohongmaoai.com/app/banner/list', // 使用100%正确的URL
        queryParameters: {'bannerPlace': '4'},
        options: Options(
          headers: {'Authorization': authViewModel.token},
        ),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) =>
            (json as List).map((item) => BannerEntity.fromJson(item)).toList(),
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final List<String> fetchedUrls =
            apiResponse.data!.map((banner) => banner.imgUrl).toList();
        if (mounted) {
          setState(() {
            _bannerImageUrls = fetchedUrls;
            _isBannerLoading = false;
          });
          _startBannerTimer();
        }
      } else {
        if (mounted) setState(() => _isBannerLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isBannerLoading = false);
      debugPrint('获取Banner失败: $e');
    }
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    if (_bannerImageUrls.isEmpty) return;
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerPageController.hasClients) {
        int nextPage =
            (_bannerPageController.page!.round() + 1) % _bannerImageUrls.length;
        _bannerPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

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
        Image.asset('assets/images/cat9.jpg', fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(color: Colors.black.withOpacity(0.2)),
        ),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const AppTopBar(),
                const SizedBox(height: 20),
                _buildMenuButtons(context),
                const SizedBox(height: 20),
                _buildBanner(),
                const SizedBox(height: 24),
                const Text('相册',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('拍摄完的AI作品显示在此',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 20),
                _buildImageGrid(),
                const SizedBox(height: 30),
                _buildCreateButton(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    if (_isBannerLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_bannerImageUrls.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
            child: Text('暂无推荐内容', style: TextStyle(color: Colors.white70))),
      );
    }
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _bannerPageController,
            itemCount: _bannerImageUrls.length,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: _bannerImageUrls[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.black.withOpacity(0.2)),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Colors.white70),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 10.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bannerImageUrls.length,
                (index) => _buildDotIndicator(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        itemCount: _gridImagePaths.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (context, index) {
          final imagePath = _gridImagePaths[index];
          return GestureDetector(
            onTap: () => context.push('/photo-view', extra: imagePath),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Hero(
                tag: imagePath,
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),
          );
        },
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

  Widget _buildCreateButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.camera_alt, color: Colors.white),
      label: const Text('点击制作',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7A5CFA),
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
}
