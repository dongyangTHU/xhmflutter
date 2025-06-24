// lib/pages/creation_store_page.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // 1. 导入 Provider
import '../viewmodels/user_viewmodel.dart'; // 2. 导入 UserViewModel

class CreationStorePage extends StatefulWidget {
  const CreationStorePage({super.key});

  @override
  State<CreationStorePage> createState() => _CreationStorePageState();
}

class _CreationStorePageState extends State<CreationStorePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              children: const [
                PetPhotoView(),
                HumanPetPhotoView(),
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
        onPressed: () => context.pop(),
      ),
      title: const Text(
        '写真商店',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      centerTitle: true,
      actions: [
        // --- 核心修改: 监听 UserViewModel 来动态显示余额 ---
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Consumer<UserViewModel>(
            builder: (context, userViewModel, child) {
              final balance = userViewModel.userInfo?.balance ?? '...';
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.ac_unit, color: Colors.yellow, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      balance, // 3. 使用动态余额
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
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

// ... PetPhotoView 和 HumanPetPhotoView 等其他代码保持不变 ...

class PetPhotoView extends StatefulWidget {
  const PetPhotoView({super.key});

  @override
  State<PetPhotoView> createState() => _PetPhotoViewState();
}

class _PetPhotoViewState extends State<PetPhotoView> {
  late final PageController _bannerPageController;
  int _bannerCurrentPage = 0;
  Timer? _bannerTimer;

  final List<String> _bannerImages = [
    'assets/images/cat2.jpg',
    'assets/images/cat5.jpg',
    'assets/images/cat6.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    if (!mounted) return;
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_bannerPageController.hasClients || _bannerImages.isEmpty) return;
      int nextPage = (_bannerCurrentPage + 1) % _bannerImages.length;
      _bannerPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAutoScrollBanner(),
          const SizedBox(height: 24),
          _buildSection(context, '热门', '时下最喜爱的套系', isPet: true),
          const SizedBox(height: 24),
          _buildSection(context, '优惠', '超值限时特价套系', isPet: true),
        ],
      ),
    );
  }

  Widget _buildAutoScrollBanner() {
    if (_bannerImages.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _bannerPageController,
            itemCount: _bannerImages.length,
            onPageChanged: (page) {
              setState(() {
                _bannerCurrentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(_bannerImages[index], fit: BoxFit.cover),
              );
            },
          ),
          Positioned(
            bottom: 10.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_bannerImages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: 8.0,
                  width: _bannerCurrentPage == index ? 24.0 : 8.0,
                  decoration: BoxDecoration(
                    color: _bannerCurrentPage == index
                        ? Colors.white
                        : Colors.white54,
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
}

class HumanPetPhotoView extends StatelessWidget {
  const HumanPetPhotoView({super.key});

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
          _buildSection(context, '热门', '时下最喜爱的套系', isPet: false),
          const SizedBox(height: 24),
          _buildSection(context, '优惠', '超值限时特价套系', isPet: true),
        ],
      ),
    );
  }
}

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
          const Text('更多套系 >',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, index) {
            return _buildPhotoCard(
                context: context, isPet: isPet, index: index);
          },
        ),
      ),
    ],
  );
}

Widget _buildPhotoCard(
    {required BuildContext context, required bool isPet, required int index}) {
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

  return GestureDetector(
    onTap: () {
      context.push('/package-detail');
    },
    child: Container(
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
                  const Icon(Icons.ac_unit, color: Colors.yellow, size: 16),
                  const SizedBox(width: 2),
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
    ),
  );
}
