// lib/pages/package_detail_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class PackageDetailPage extends StatefulWidget {
  const PackageDetailPage({super.key});

  @override
  State<PackageDetailPage> createState() => _PackageDetailPageState();
}

class _PackageDetailPageState extends State<PackageDetailPage> {
  // 硬编码的示例数据
  final List<String> _backgroundImages = [
    'assets/images/cat1.jpg',
    'assets/images/cat2.jpg',
    'assets/images/cat3.jpg',
  ];
  final List<String> _userShowcaseImages = [
    'assets/images/cat5.jpg',
    'assets/images/cat6.jpg',
    'assets/images/cat7.jpg',
    'assets/images/cat8.jpg',
  ];
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Scaffold 并允许 body 延伸到 AppBar 后面
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // 1. 顶部的背景图轮播
          _buildBackgroundSlider(),

          // 2. 下方的玻璃材质信息面板
          _buildInfoSheet(),

          // 3. 底部的“开始创作”按钮
          _buildBottomButton(),
        ],
      ),
    );
  }

  // 构建背景图轮播
  Widget _buildBackgroundSlider() {
    return Positioned.fill(
      child: PageView.builder(
        controller: _pageController,
        itemCount: _backgroundImages.length,
        itemBuilder: (context, index) {
          return Image.asset(
            _backgroundImages[index],
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  // 构建信息面板
  Widget _buildInfoSheet() {
    // 使用 DraggableScrollableSheet 可以实现可拖动的效果，这里为简化先用 Positioned
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      // 面板高度占据屏幕约 65%
      height: MediaQuery.of(context).size.height * 0.65,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // 底部留出按钮空间
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 套系名称和价格
                  _buildTitleAndPrice(),
                  const SizedBox(height: 16),
                  // 套系文字简介
                  const Text(
                    '这是一款充满节日气氛的写真套系，让你的爱宠化身派对焦点。我们精选了多种配饰和场景，通过AI技术生成独一无二的艺术照片。',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '其他用户作品展示',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // 其他用户返图
                  _buildUserShowcase(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建标题和价格
  Widget _buildTitleAndPrice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Text(
            '艺术相框名画艺术相框名画艺术相框名画',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: const [
            Icon(Icons.ac_unit, color: Colors.yellow, size: 20),
            SizedBox(width: 4),
            Text(
              '288',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
      ],
    );
  }

  // 构建用户作品展示区
  Widget _buildUserShowcase() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _userShowcaseImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                _userShowcaseImages[index],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  // 构建底部按钮
  Widget _buildBottomButton() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 30, // 距离底部安全区域
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7A5CFA),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          // 此处应跳转到原型图的第二个页面，后续开发
        },
        child: const Text(
          '开始创作',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
