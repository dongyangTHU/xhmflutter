import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
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
  // --- 数据和网络请求相关 State ---
  final Dio _dio = Dio();
  bool _isLoading = true;
  String? _error;
  List<BannerEntity> _banners = [];
  List<PortraitEntity> _historyPortraits = [];

  // --- Banner 轮播相关 State ---
  late final PageController _bannerPageController;
  int _currentPage = 0;
  Timer? _bannerTimer;

  // --- 滚动和UI效果相关 State ---
  final ScrollController _scrollController = ScrollController();
  double _overlayOpacity = 0.0;
  double _blurAmount = 0.0;
  double _topBarOffset = 0.0;
  bool _isSnapping = false;

  // TopBar的初始顶部间距
  static const double _topBarInitialPadding = 60.0;

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
        maxWidth: 90));

    // 使用简单的setState监听器来更新UI
    _scrollController.addListener(_onScroll);
    _fetchData();
  }

  void _onScroll() {
    // 恢复原来的滚动监听逻辑，用于计算模糊、蒙层和TopBar偏移
    const double scrollThreshold = 250.0;
    const double maxOpacity = 0.5;
    const double maxBlur = 15.0;

    final introHeight = MediaQuery.of(context).size.height - 100.0;
    const topBarContainerHeight = 60.0;

    final offset = _scrollController.offset;

    final newOpacity = (offset / scrollThreshold).clamp(0.0, 1.0) * maxOpacity;
    final newBlur = (offset / scrollThreshold).clamp(0.0, 1.0) * maxBlur;

    // TopBar跟随滚动的偏移计算
    final newTopBarOffset = -(offset - introHeight)
        .clamp(0.0, _topBarInitialPadding + topBarContainerHeight);

    if (mounted &&
        (_overlayOpacity != newOpacity ||
            _blurAmount != newBlur ||
            _topBarOffset != newTopBarOffset)) {
      setState(() {
        _overlayOpacity = newOpacity;
        _blurAmount = newBlur;
        _topBarOffset = newTopBarOffset;
      });
    }
  }

  // --- 任务2: 优化吸附动画逻辑 ---
  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isSnapping) return false;

    // 当用户停止拖拽且滚动空闲时，触发判断
    if (notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle) {
      // 定义吸附点 (第一屏的高度)
      final double snapPosition = MediaQuery.of(context).size.height - 100.0;
      final double currentOffset = _scrollController.offset;

      // 如果已在内容深处，或在顶部，则不处理
      if (currentOffset > snapPosition || currentOffset < 0) return false;

      // --- 优化点 1: 降低吸附阈值 ---
      // 原来的阈值是 snapPosition / 2，现在改为 snapPosition / 5
      // 这意味着用户只需滚动超过第一屏高度的20%，就会触发吸附，感觉更灵敏
      final double snapThreshold = snapPosition / 5;

      // 决定目标位置
      final double target = (currentOffset >= snapThreshold) ? snapPosition : 0.0;

      // 如果当前位置和目标位置已经很接近，则不执行动画
      if ((target - currentOffset).abs() < 1.0) return false;

      _isSnapping = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // --- 优化点 2: 调整动画速度 ---
          _scrollController
              .animateTo(
                target,
                // 原来是 300ms，增加约10%使其变慢，变为 330ms
                // 你可以在这里调整动画时长，值越大，动画越慢
                duration: const Duration(milliseconds: 330),
                curve: Curves.easeOutCubic,
              )
              .whenComplete(() {
            if (mounted) {
              _isSnapping = false;
            }
          });
        } else {
          _isSnapping = false;
        }
      });
      // 返回true，消费掉这个通知，防止其他物理效果（如自动再滑动一下）的干扰
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _bannerPageController.dispose();
    _bannerTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const double bannerPeekHeight = 100.0; // Banner窥视高度

    return Scaffold(
      backgroundColor: Colors.black,
      body: NotificationListener<ScrollNotification>(
        // 将监听器放在最外层
        onNotification: _handleScrollNotification,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景层
            Image.asset('assets/images/cat1.jpg', fit: BoxFit.cover),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _blurAmount, sigmaY: _blurAmount),
              child: Container(color: Colors.black.withOpacity(0.01)),
            ),
            Container(
              color: Colors.black.withOpacity(_overlayOpacity),
            ),

            // 内容层 (恢复为原来的 CustomScrollView 结构)
            RefreshIndicator(
              onRefresh: _fetchData,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  // Sliver 1: 首页区域
                  SliverToBoxAdapter(
                    child: Container(
                      height: screenHeight - bannerPeekHeight,
                      color: Colors.transparent,
                      child: SafeArea(
                        bottom: false,
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 40,
                              left: 16,
                              right: 16,
                              child: _buildMenuButtons(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Sliver 2, 3, 4: 主内容区
                  SliverToBoxAdapter(child: _buildBannerSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverToBoxAdapter(child: _buildAlbumSection()),
                  SliverToBoxAdapter(child: const SizedBox(height: 120)),
                ],
              ),
            ),

            // UI层: TopBar
            Positioned(
              top: _topBarInitialPadding,
              left: 0,
              right: 0,
              child: Transform.translate(
                offset: Offset(0, _topBarOffset),
                child: const AppTopBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 无需更改的私有方法 ---

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
      if (_bannerPageController.hasClients && _banners.length > 1) {
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

  void _onBannerTapped(BannerEntity banner) {
    debugPrint(
        "Banner Tapped: title=${banner.title}, type=${banner.bannerType}");
    switch (banner.bannerType) {
      case '2':
        context.push('/creation-store');
        break;
      case '3':
        context.push('/membership-recharge');
        break;
      default:
        debugPrint("未知的 Banner 类型: ${banner.bannerType}");
        break;
    }
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMenuButton(context, Icons.add_circle, '开始创作', '/creation-store'),
        _buildMenuButton(context, Icons.pets, '我的宠物', null),
        _buildMenuButton(context, Icons.photo_library, '每日写真', null),
        _buildMenuButton(context, Icons.back_hand, '偷只小猫', null),
      ],
    );
  }

  Widget _buildMenuButton(
      BuildContext context, IconData icon, String label, String? route) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          context.push(route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 任务1: 为按钮添加圆形投影
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25), // 投影颜色
                  spreadRadius: 1, // 投影扩展
                  blurRadius: 4, // 投影模糊半径
                  offset: const Offset(0, 2), // 投影位置 (向下偏移2)
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svgs/menu_button_bg.svg',
                  width: 56,
                  height: 56,
                ),
                Icon(icon, color: Colors.white, size: 24),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: "PingFang SC",
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('相册',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: "PingFang SC",
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('拍摄完的AI作品显示在此',
              style: TextStyle(
                  color: Color(0xFF808080),
                  fontSize: 14,
                  fontFamily: "PingFang SC",
                  fontWeight: FontWeight.w400)),
          const SizedBox(height: 20),
          if (!_isLoading)
            _historyPortraits.isEmpty
                ? _buildEmptyAlbumState(context)
                : _buildImageGrid(),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
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
    );
  }

  Widget _buildEmptyAlbumState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            '还没有写真作品',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: "PingFang SC",
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '挑选心仪的写真套系\n定格宠物的无限瞬间',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF808080),
              fontSize: 14,
              fontFamily: "PingFang SC",
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              context.push('/creation-store');
            },
            child: SizedBox(
              width: 200,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svgs/create_button_bg.svg',
                    fit: BoxFit.fill,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/ic_home_cam.png',
                        width: 22,
                        height: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '点击制作',
                        style: TextStyle(
                          color: Color(0xFFD5B2FF),
                          fontSize: 14,
                          fontFamily: "PingFang SC",
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBannerUI() {
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
              return GestureDetector(
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
            },
          ),
          if (_banners.length > 1)
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
}