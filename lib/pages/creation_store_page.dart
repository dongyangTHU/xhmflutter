// lib/pages/creation_store_page.dart

import 'package:flutter/material.dart';
import 'dart:async';

class CreationStorePage extends StatefulWidget {
  const CreationStorePage({super.key});

  @override
  State<CreationStorePage> createState() => _CreationStorePageState();
}

class _CreationStorePageState extends State<CreationStorePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _bannerPageController;
  int _bannerCurrentPage = 0;
  Timer? _bannerTimer;

  // 为两个Tab分别定义Banner图片列表
  final List<String> _petBannerImagePaths = [
    'assets/images/cat2.jpg',
    'assets/images/cat5.jpg',
    'assets/images/cat6.jpg',
  ];
  final List<String> _humanPetBannerImagePaths = [
    'assets/images/cat1.jpg',
    'assets/images/cat3.jpg',
    'assets/images/cat4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bannerPageController = PageController();
    _startBannerTimer();

    // 监听Tab切换，以便在需要时可以重置Banner状态或加载不同数据
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _bannerPageController.jumpToPage(0); // 切换Tab时重置Banner到第一页
        setState(() {
          _bannerCurrentPage = 0;
        });
      }
    });
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_bannerPageController.hasClients) return;

      // 根据当前激活的Tab来决定Banner的总页数
      int pageCount = _tabController.index == 0
          ? _petBannerImagePaths.length
          : _humanPetBannerImagePaths.length;

      if (pageCount == 0) return;

      int nextPage = (_bannerCurrentPage + 1) % pageCount;
      _bannerPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bannerPageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  static const Color _scaffoldBgColor = Color(0xFF1A182E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 宠物写真 视图
                PetPhotoView(
                  bannerController: _bannerPageController,
                  bannerImages: _petBannerImagePaths,
                  currentPage: _bannerCurrentPage,
                  onPageChanged: (page) {
                    setState(() {
                      _bannerCurrentPage = page;
                    });
                  },
                ),
                // 人宠合照 视图
                HumanPetPhotoView(
                  bannerController: _bannerPageController,
                  bannerImages: _humanPetBannerImagePaths,
                  currentPage: _bannerCurrentPage,
                  onPageChanged: (page) {
                    setState(() {
                      _bannerCurrentPage = page;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _scaffoldBgColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        '写真商店',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorColor: const Color(0xFF7A5CFA),
      indicatorWeight: 3,
      indicatorPadding: const EdgeInsets.symmetric(horizontal: 24),
      tabs: const [
        Tab(text: '宠物写真'),
        Tab(text: '人宠合照'),
      ],
    );
  }
}

// 宠物写真视图
class PetPhotoView extends StatelessWidget {
  final PageController bannerController;
  final List<String> bannerImages;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const PetPhotoView({
    super.key,
    required this.bannerController,
    required this.bannerImages,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 SingleChildScrollView + Column 的正确布局方式
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAutoScrollBanner(
            context,
            bannerController,
            bannerImages,
            currentPage,
            onPageChanged,
          ),
          const SizedBox(height: 24),
          _buildSection(context, '热门', '时下最喜爱的套系', isPet: true),
          const SizedBox(height: 24),
          _buildSection(context, '优惠', '超值限时特价套系', isPet: true),
        ],
      ),
    );
  }
}

// 人宠合照视图
class HumanPetPhotoView extends StatelessWidget {
  final PageController bannerController;
  final List<String> bannerImages;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const HumanPetPhotoView({
    super.key,
    required this.bannerController,
    required this.bannerImages,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              '创建个人AI形象',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {},
          ),
          const SizedBox(height: 24),
          _buildAutoScrollBanner(
            context,
            bannerController,
            bannerImages,
            currentPage,
            onPageChanged,
          ),
          const SizedBox(height: 24),
          _buildSection(context, '热门', '时下最喜爱的套系', isPet: false),
          const SizedBox(height: 24),
          _buildSection(context, '优惠', '超值限时特价套系', isPet: true),
        ],
      ),
    );
  }
}

// --- 通用辅助方法 ---

// 构建自动翻页Banner
Widget _buildAutoScrollBanner(
  BuildContext context,
  PageController controller,
  List<String> images,
  int currentPage,
  ValueChanged<int> onPageChanged,
) {
  if (images.isEmpty) return const SizedBox.shrink(); // 如果没有图片则不显示

  return SizedBox(
    height: 150,
    child: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: controller,
          itemCount: images.length,
          onPageChanged: onPageChanged,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(images[index], fit: BoxFit.cover),
            );
          },
        ),
        Positioned(
          bottom: 10.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 8.0,
                width: currentPage == index ? 24.0 : 8.0,
                decoration: BoxDecoration(
                  color: currentPage == index ? Colors.white : Colors.white54,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }),
          ),
        ),
      ],
    ),
  );
}

// 构建内容分区
Widget _buildSection(
  BuildContext context,
  String title,
  String subtitle, {
  required bool isPet,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          Text('更多套系 >', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, index) {
            return _buildPhotoCard(isPet: isPet, index: index);
          },
        ),
      ),
    ],
  );
}

// 构建写真套系卡片
Widget _buildPhotoCard({required bool isPet, required int index}) {
  final petImages = [
    'assets/images/cat5.jpg',
    'assets/images/cat6.jpg',
    'assets/images/cat7.jpg',
  ];
  final humanPetImages = [
    'assets/images/cat1.jpg',
    'assets/images/cat2.jpg',
    'assets/images/cat3.jpg',
  ];
  final images = isPet ? petImages : humanPetImages;
  final price = isPet ? '299' : '599';

  return Container(
    width: 160,
    margin: const EdgeInsets.only(right: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              images[index % images.length],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '套系名称',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '节日盛典 | 8.8万用户使用',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.yellow, size: 16),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
