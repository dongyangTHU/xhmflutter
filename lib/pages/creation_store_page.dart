// lib/pages/creation_store_page.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// --- 核心修改：导入必要的包 ---
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart'; // 导入AuthViewModel
import '../models/api_response.dart'; // 导入统一响应模型
import '../models/banner_entity.dart'; // 导入Banner模型

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
      title: const Text('写真商店',
          style: TextStyle(color: Colors.white, fontSize: 18)),
      centerTitle: true,
      actions: [
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
                      balance,
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

class PetPhotoView extends StatefulWidget {
  const PetPhotoView({super.key});
  @override
  State<PetPhotoView> createState() => _PetPhotoViewState();
}

class _PetPhotoViewState extends State<PetPhotoView> {
  late final PageController _bannerPageController;
  int _bannerCurrentPage = 0;
  Timer? _bannerTimer;
  final Dio _dio = Dio();

  bool _isLoading = true;
  String? _error;
  List<BannerEntity> _banners = [];

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController();
    _fetchBanners();
  }

  // --- 核心修改: 修正获取 Banner 数据的 API 调用参数 ---
  Future<void> _fetchBanners() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authViewModel = context.read<AuthViewModel>();
    final token = authViewModel.token;

    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _error = "用户未登录，无法加载数据";
          _isLoading = false;
        });
      }
      return;
    }

    try {
      // 调用v1.0的Banner接口，并传入正确的 '5' 作为 bannerPlace
      // 这个 '5' 是从 v1.0 的 lib/pages/ai/ai_logic.dart 文件中找到的
      final response = await _dio.get(
        'https://www.xiaohongmaoai.com/app/banner/list',
        queryParameters: {'bannerPlace': '5'}, // **关键修正: 使用 '5'**
        options: Options(headers: {'Authorization': token}),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => (json as List).map((i) => BannerEntity.fromJson(i)).toList(),
      );

      if (mounted) {
        if (apiResponse.isSuccess && apiResponse.data != null) {
          setState(() {
            _banners = apiResponse.data!;
            _isLoading = false;
          });
          _startBannerTimer();
        } else {
          setState(() {
            _error = "获取Banner失败: ${apiResponse.msg}";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "网络请求失败: $e";
          _isLoading = false;
        });
      }
    }
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    if (!mounted || _banners.isEmpty) return;
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_bannerPageController.hasClients) return;
      int nextPage = (_bannerCurrentPage + 1) % _banners.length;
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
    if (_isLoading) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child:
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error != null) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Center(
            child: Text('加载失败: $_error',
                style: const TextStyle(color: Colors.white70))),
      );
    }

    if (_banners.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: const Center(
            child: Text('暂无推荐内容', style: TextStyle(color: Colors.white70))),
      );
    }

    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _bannerPageController,
            itemCount: _banners.length,
            onPageChanged: (page) => setState(() => _bannerCurrentPage = page),
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: CachedNetworkImage(
                imageUrl: _banners[index].imgUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.white.withOpacity(0.1),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 10.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (index) {
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

// 以下代码保持不变
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
            label:
                const Text('创建个人AI形象', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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

Widget _buildSection(BuildContext context, String title, String subtitle,
    {required bool isPet}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          GestureDetector(
            onTap: () {
              context.push('/packages-by-category', extra: title);
            },
            child: const Text('更多套系 >',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
          ),
        ],
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, index) =>
              _buildPhotoCard(context: context, isPet: isPet, index: index),
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
    'assets/images/cat7.jpg'
  ];
  final humanPetImages = [
    'assets/images/cat1.jpg',
    'assets/images/cat2.jpg',
    'assets/images/cat3.jpg'
  ];
  final images = isPet ? petImages : humanPetImages;
  final price = isPet ? '299' : '599';

  return GestureDetector(
    onTap: () => context.push('/package-detail'),
    child: Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(images[index % images.length],
                  fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('套系名称',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text('节日盛典 | 8.8万用户使用',
                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.ac_unit, color: Colors.yellow, size: 16),
                  const SizedBox(width: 2),
                  Text(price,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
