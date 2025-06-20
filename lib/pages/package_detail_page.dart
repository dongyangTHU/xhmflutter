// lib/pages/package_detail_page.dart

import 'dart:async'; // 引入
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PackageDetailPage extends StatefulWidget {
  const PackageDetailPage({super.key});

  @override
  State<PackageDetailPage> createState() => _PackageDetailPageState();
}

class _PackageDetailPageState extends State<PackageDetailPage> {
  final List<String> _backgroundImages = [
    'assets/images/cat1.jpg',
    'assets/images/cat2.jpg',
    'assets/images/cat3.jpg',
    'assets/images/cat4.jpg',
    'assets/images/cat5.jpg',
  ];
  final List<String> _userShowcaseImages = [
    'assets/images/cat5.jpg',
    'assets/images/cat6.jpg',
    'assets/images/cat7.jpg',
    'assets/images/cat8.jpg',
    'assets/images/cat1.jpg',
    'assets/images/cat2.jpg',
  ];
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // --- 关键修改 1: 添加 Timer ---
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    // 页面初始化时，启动定时器
    _startBannerTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // 页面销毁时，取消定时器，防止内存泄漏
    _bannerTimer?.cancel();
    super.dispose();
  }

  // --- 关键修改 2: 实现自动轮播逻辑 ---
  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_pageController.hasClients) return;

      int nextPage = (_currentPage + 1) % _backgroundImages.length;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          _buildTopRightButton(),
        ],
      ),
      body: Stack(
        children: [
          _buildBackgroundSlider(),
          _buildDraggableInfoSheet(),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildTopRightButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black.withOpacity(0.25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            // --- 关键修改 3: 统一冻干图标 ---
            Icon(Icons.ac_unit, color: Colors.yellow, size: 16),
            SizedBox(width: 4),
            Text(
              '1502937',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundSlider() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _backgroundImages.length,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
          itemBuilder: (context, index) {
            return Image.asset(
              _backgroundImages[index],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
          },
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.28,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _backgroundImages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                height: 6.0,
                width: _currentPage == index ? 18.0 : 6.0,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(_currentPage == index ? 0.9 : 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableInfoSheet() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const initialSize = 0.25;
    const minSize = 0.25;
    const maxSize = 0.9;

    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      builder: (BuildContext context, ScrollController scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTitleAndPrice(),
                    const SizedBox(height: 24),
                    const Text(
                      '用户照',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildUserShowcase(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleAndPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: const [
                Text(
                  '套系名称',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.star, color: Colors.yellow, size: 20),
              ],
            ),
            Row(
              children: const [
                // --- 关键修改 3: 统一冻干图标 ---
                Icon(Icons.ac_unit, color: Colors.yellow, size: 20),
                SizedBox(width: 4),
                Text(
                  '299',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          '萌宠日常 | 8.8万用户已使用',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildUserShowcase() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _userShowcaseImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            _userShowcaseImages[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_enhance_outlined,
                        color: Colors.white),
                    label: const Text(
                      '拍同款',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
