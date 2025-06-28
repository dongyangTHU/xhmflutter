// lib/pages/creation_store_page.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/api_response.dart';
import '../models/banner_entity.dart';

// --- 屏幕适配工具 (无变化) ---
class ScaleUtil {
  static const double _designWidth = 750.0;
  static double _screenWidth = 0;

  static void init(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
  }

  static double scale(double value) {
    if (_screenWidth == 0) return value;
    return value * _screenWidth / _designWidth;
  }
}

class CreationStorePage extends StatefulWidget {
  const CreationStorePage({super.key});

  @override
  State<CreationStorePage> createState() => _CreationStorePageState();
}

class _CreationStorePageState extends State<CreationStorePage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _tabController = ValueNotifier('pet');

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() {
      if (!mounted || !_pageController.hasClients) return;
      if (_tabController.value == 'pet' && _pageController.page != 0) {
        _pageController.animateToPage(0, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      } else if (_tabController.value == 'human_pet' && _pageController.page != 1) {
        _pageController.animateToPage(1, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);

    // --- 核心修复：使用 Stack 作为根 Widget 来确保背景图在最底层 ---
    return Stack(
      children: [
        // 背景层
        Image.asset(
          'assets/images/bg_create_store.png',
          // 确保图片填满整个屏幕
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        // 内容层
        Scaffold(
          // 必须将 Scaffold 的背景设置为透明，否则它会覆盖 Stack 底层的图片
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildCustomHeader(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      _tabController.value = index == 0 ? 'pet' : 'human_pet';
                    },
                    children: const [
                      PetPhotoView(),
                      HumanPetPhotoView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      // 头部背景保持透明，以免遮挡背景图
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: ScaleUtil.scale(32),
        vertical: ScaleUtil.scale(20),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
            onPressed: () => context.pop(),
          ),
          const Spacer(),
          _buildCustomSvgSwitch(),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildCustomSvgSwitch() {
    const double switchWidth = 352.0;
    const double switchHeight = 70.0;

    return Container(
      width: ScaleUtil.scale(switchWidth),
      height: ScaleUtil.scale(switchHeight),
      decoration: BoxDecoration(
        color: Colors.transparent, // 开关背景透明
        borderRadius: BorderRadius.circular(ScaleUtil.scale(35)),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ValueListenableBuilder<String>(
        valueListenable: _tabController,
        builder: (context, value, child) {
          final isPetSelected = value == 'pet';
          return LayoutBuilder(
            builder: (context, constraints) {
              final sliderSlotWidth = constraints.maxWidth / 2;
              final sliderSlotHeight = constraints.maxHeight;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    left: isPetSelected ? 0 : sliderSlotWidth,
                    child: Container(
                      width: sliderSlotWidth,
                      height: sliderSlotHeight,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/svgs/switch_create_store.svg',
                          width: sliderSlotWidth * 0.85,
                          height: sliderSlotHeight * 0.85,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSwitchTab('pet', '宠物写真'),
                      ),
                      Expanded(
                        child: _buildSwitchTab('human_pet', '人宠合照'),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSwitchTab(String value, String text) {
    // 使用 ValueListenableBuilder 来实时响应 _tabController 的变化
    return ValueListenableBuilder<String>(
        valueListenable: _tabController,
        builder: (context, currentValue, child) {
          final isSelected = currentValue == value;
          final activeStyle = TextStyle(
            color: const Color(0xFF211815),
            fontWeight: FontWeight.w600,
            fontFamily: "PingFang SC",
            fontSize: ScaleUtil.scale(21),
          );
          final inactiveStyle = TextStyle(
            color: Colors.white,
            fontFamily: "PingFang SC",
            fontSize: ScaleUtil.scale(21),
          );

          return GestureDetector(
            onTap: () {
              if (_tabController.value != value) {
                 _tabController.value = value;
              }
            },
            child: Container(
              color: Colors.transparent,
              height: double.infinity,
              alignment: Alignment.center,
              child: Text(
                text,
                style: isSelected ? activeStyle : inactiveStyle,
              ),
            ),
          );
        });
  }
}

// --- PetPhotoView, HumanPetPhotoView, _buildSection, _buildPhotoCard ---

class PetPhotoView extends StatefulWidget {
  const PetPhotoView({super.key});
  @override
  State<PetPhotoView> createState() => _PetPhotoViewState();
}

class _PetPhotoViewState extends State<PetPhotoView> with AutomaticKeepAliveClientMixin {
  final PageController _bannerPageController = PageController();
  int _bannerCurrentPage = 0;
  Timer? _bannerTimer;
  final Dio _dio = Dio();

  bool _isLoading = true;
  String? _error;
  List<BannerEntity> _banners = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // --- 优化：确保在 Widget 构建完成后再进行网络请求 ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
         _fetchBanners();
      }
    });
  }

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
      final response = await _dio.get(
        'https://www.xiaohongmaoai.com/app/banner/list',
        queryParameters: {'bannerPlace': '5'},
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
    super.build(context);
    // SingleChildScrollView 本身是透明的，不会遮挡背景
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: ScaleUtil.scale(32)),
      child: Column(
        children: [
          SizedBox(height: ScaleUtil.scale(30)),
          _buildAutoScrollBanner(),
          SizedBox(height: ScaleUtil.scale(48)),
          _buildSection(context, '热门', '时下最喜爱的套系', isPet: true),
          SizedBox(height: ScaleUtil.scale(48)),
          _buildSection(context, '优惠', '超值限时特价套系', isPet: true),
          SizedBox(height: ScaleUtil.scale(48)),
          _buildSection(context, '萌宠日常', '记录宠物的每个可爱瞬间', isPet: true),
          SizedBox(height: ScaleUtil.scale(40)),
        ],
      ),
    );
  }

  Widget _buildAutoScrollBanner() {
    final bannerHeight = ScaleUtil.scale(250);

    if (_isLoading) {
      return Container(
        height: bannerHeight,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1), // 半透明背景不会完全遮挡
          borderRadius: BorderRadius.circular(ScaleUtil.scale(32)),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error != null) {
      return Container(
        height: bannerHeight,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ScaleUtil.scale(32)),
        ),
        child: Center(
            child: Text('加载失败: $_error',
                style: const TextStyle(color: Colors.white70))),
      );
    }

    if (_banners.isEmpty) {
      return Container(
        height: bannerHeight,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ScaleUtil.scale(32)),
        ),
        child: const Center(
            child: Text('暂无推荐内容', style: TextStyle(color: Colors.white70))),
      );
    }

    return SizedBox(
      height: bannerHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _bannerPageController,
            itemCount: _banners.length,
            onPageChanged: (page) => setState(() => _bannerCurrentPage = page),
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(ScaleUtil.scale(32)),
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

class HumanPetPhotoView extends StatelessWidget {
  const HumanPetPhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: ScaleUtil.scale(32)),
      child: Column(
        children: [
          SizedBox(height: ScaleUtil.scale(48)),
          _buildSection(context, '热门', '时下最喜爱的套系', isPet: false),
          SizedBox(height: ScaleUtil.scale(48)),
          _buildSection(context, '优惠', '超值限时特价套系', isPet: false),
          SizedBox(height: ScaleUtil.scale(40)),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: ScaleUtil.scale(34),
                      fontWeight: FontWeight.w600,
                      fontFamily: "PingFang SC")),
              SizedBox(height: ScaleUtil.scale(8)),
              Text(subtitle,
                  style: TextStyle(
                      color: const Color(0xFF808080),
                      fontSize: ScaleUtil.scale(21),
                      fontWeight: FontWeight.w400,
                      fontFamily: "PingFang SC")),
            ],
          ),
          GestureDetector(
            onTap: () {
              context.push('/packages-by-category', extra: title);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScaleUtil.scale(24),
                vertical: ScaleUtil.scale(10),
              ),
              decoration: ShapeDecoration(
                shape: StadiumBorder(
                  side: BorderSide(
                    color: const Color(0xFF808080),
                    width: 1.0,
                  ),
                ),
              ),
              child: Text('更多套系',
                  style: TextStyle(
                      color: const Color(0xFF808080),
                      fontSize: ScaleUtil.scale(21),
                      fontWeight: FontWeight.w400,
                      fontFamily: "PingFang SC")),
            ),
          ),
        ],
      ),
      SizedBox(height: ScaleUtil.scale(32)),
      SizedBox(
        height: ScaleUtil.scale(341),
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

  return GestureDetector(
    onTap: () => context.push('/package-detail'),
    child: Container(
      width: ScaleUtil.scale(281),
      margin: EdgeInsets.only(right: ScaleUtil.scale(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ScaleUtil.scale(20)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              images[index % images.length],
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: ScaleUtil.scale(24),
              left: ScaleUtil.scale(24),
              right: ScaleUtil.scale(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('套系名称',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScaleUtil.scale(25),
                          fontWeight: FontWeight.w400,
                          fontFamily: "PingFang SC")),
                  SizedBox(height: ScaleUtil.scale(4)),
                  Text('节日盛典 | 8.8万用户使用',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: ScaleUtil.scale(12),
                          fontWeight: FontWeight.w400,
                          fontFamily: "PingFang SC")),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}