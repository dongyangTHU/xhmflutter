import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _bannerPageController;
  int _currentPage = 0;
  Timer? _bannerTimer;

  final List<String> _bannerImagePaths = [
    'assets/images/cat1.jpg',
    'assets/images/cat2.jpg',
    'assets/images/cat3.jpg',
    'assets/images/cat4.jpg',
  ];
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
    _bannerPageController.addListener(() {
      if (_bannerPageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _bannerPageController.page!.round();
        });
      }
    });
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerPageController.hasClients) {
        int nextPage = (_currentPage + 1) % _bannerImagePaths.length;
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
            // ===================================================================
            // KEY FIX: 这里的 physics 属性已被移除（或注释掉）。
            // 这是解决问题的核心。移除后，内部的滚动视图将不再与外部的PageView竞争手势，
            // 从而允许用户在页面顶部向下滑动时，能够正确地触发返回IntroPage的操作。
            // ===================================================================
            // physics: const BouncingScrollPhysics(
            //   parent: AlwaysScrollableScrollPhysics(),
            // ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white.withOpacity(0.7),
                    size: 24,
                  ),
                ),
                _buildTopBar(),
                const SizedBox(height: 20),
                _buildMenuButtons(),
                const SizedBox(height: 20),
                _buildBanner(),
                const SizedBox(height: 24),
                const Text(
                  '相册',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '拍摄完的AI作品显示在此',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
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

  // --- 所有 _build* 方法保持不变 ---
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/256.png'),
                radius: 20,
              ),
              SizedBox(width: 8),
              Text(
                '点击会有惊喜',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: const [
                Icon(Icons.shield, color: Colors.yellow, size: 16),
                SizedBox(width: 4),
                Text(
                  '1502937',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '充值',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMenuButton(Icons.add_circle, '开始创作'),
          _buildMenuButton(Icons.pets, '我的宠物'),
          _buildMenuButton(Icons.photo_library, '每日写真'),
          _buildMenuButton(Icons.back_hand, '偷只小猫'),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _bannerPageController,
            itemCount: _bannerImagePaths.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(_bannerImagePaths[index]),
                    fit: BoxFit.cover,
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
                _bannerImagePaths.length,
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
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(_gridImagePaths[index], fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.camera_alt, color: Colors.white),
      label: const Text(
        '点击制作',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
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
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
