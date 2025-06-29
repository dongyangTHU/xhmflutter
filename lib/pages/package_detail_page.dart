// lib/pages/package_detail_page.dart

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// --- Main Page Widget ---
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

  static const int _infiniteScrollInitialPage = 50000;
  late PageController _pageController;
  int _currentPage = _infiniteScrollInitialPage;
  Timer? _bannerTimer;
  
  // --- 新增状态变量 ---
  bool _isUserInteracting = false; // 用户是否正在手动滑动
  bool _isCreationFlowOpen = false; // 拍摄信息确认是否打开

  final String _packageName = '套系名称';
  final String _packagePrice = '299';

  static const double _minSheetSize = 0.23;
  static const double _maxSheetSize = 0.83;
  double _sheetExtent = _minSheetSize;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _infiniteScrollInitialPage);
    _startBannerTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // --- 优化：只有在用户没有手动滑动时才自动切换 ---
      if (!mounted || !_pageController.hasClients || _isUserInteracting) return;
      final nextPage = _currentPage + 1;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showCreationFlow() {
    setState(() {
      _isCreationFlowOpen = true;
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (context) => _CreationFlowSheet(
        packageName: _packageName,
        packagePrice: _packagePrice,
        onClose: () {
          setState(() {
            _isCreationFlowOpen = false;
            _sheetExtent = _minSheetSize;
          });
        },
      ),
    ).then((_) {
      // 当弹窗关闭时，重置状态
      setState(() {
        _isCreationFlowOpen = false;
        _sheetExtent = _minSheetSize;
      });
    });
  }

  double _scale(BuildContext context, double figmaValue) {
    return figmaValue * (MediaQuery.of(context).size.width / 750.0);
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
        actions: const [],
      ),
      body: Stack(
        children: [
          _buildBackgroundSlider(),
          // --- 任务1: 添加顶部渐变蒙层 ---
          _buildTopGradientOverlay(),
          // --- 新增：正片叠底黑色效果 ---
          if (_isCreationFlowOpen) _buildOverlayMask(),
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              setState(() {
                _sheetExtent = notification.extent;
              });
              return true;
            },
            child: _buildDraggableInfoSheet(context),
          ),
          _buildBottomButton(context, onPressed: _showCreationFlow),
        ],
      ),
    );
  }

  // --- 新增：正片叠底黑色效果 Widget ---
  Widget _buildOverlayMask() {
    return Container(
      color: Colors.black.withOpacity(0.8), // 正片叠底黑色效果
    );
  }

  // --- 新增: 顶部渐变蒙层 Widget ---
  Widget _buildTopGradientOverlay() {
    return Container(
      // 这个蒙层从顶部向下提供一个渐变黑色效果，确保在明亮背景下返回按钮等UI元素清晰可见。
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // 渐变方向：从上到下
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // --- 自定义区域: 调整渐变颜色和不透明度 ---
            // 1. 顶部颜色和不透明度: Colors.black.withOpacity(0.6)
            //    - `0.6` 代表 60% 的黑色不透明度，值越高，顶部越暗。您可以修改这个值，范围是 0.0 (完全透明) 到 1.0 (完全不透明)。
            Colors.black.withOpacity(0.3),

            // 2. 底部颜色（渐变结束色）: Colors.transparent
            //    - 通常保持为透明色，以实现平滑过渡。
            Colors.transparent,
          ],
          // --- 自定义区域: 调整渐变范围 ---
          // 3. 渐变范围: stops: [0.0, 0.3]
          //    - `[0.0, 0.3]` 表示渐变将从屏幕的顶部 (0.0) 开始，到屏幕高度 30% (0.3) 的位置完全变为透明。
          //    - 如果您想让渐变范围更大（例如，延伸到屏幕一半），可以将其修改为 `[0.0, 0.5]`。
          stops: const [0.0, 0.2],
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
          itemCount: 100000,
          onPageChanged: (page) => setState(() => _currentPage = page),
          itemBuilder: (context, index) {
            final realIndex = index % _backgroundImages.length;
            return GestureDetector(
              onPanStart: (_) {
                setState(() {
                  _isUserInteracting = true;
                });
                // 暂停自动切换
                _bannerTimer?.cancel();
              },
              onPanEnd: (_) {
                setState(() {
                  _isUserInteracting = false;
                });
                // 重新启动自动切换
                _startBannerTimer();
              },
              child: Image.asset(
                _backgroundImages[realIndex],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            );
          },
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.255,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _backgroundImages.length,
              (index) {
                final realCurrentPage = _currentPage % _backgroundImages.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  height: 6.0,
                  width: realCurrentPage == index ? 18.0 : 6.0,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(realCurrentPage == index ? 0.9 : 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableInfoSheet(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const figmaTopRadius = 25.0;

    final progress =
        (_sheetExtent - _minSheetSize) / (_maxSheetSize - _minSheetSize);
    final clampedProgress = progress.clamp(0.0, 1.0);

    final blurValue = lerpDouble(7.5, 15.0, clampedProgress);
    final gradientStartColor = Color.lerp(
      const Color.fromRGBO(0, 0, 0, 0.5),
      const Color.fromRGBO(0, 0, 0, 0.6),
      clampedProgress,
    );

    // --- 优化：拍摄信息确认时完全隐藏底边栏 ---
    if (_isCreationFlowOpen) {
      return const SizedBox.shrink();
    }

    return DraggableScrollableSheet(
      initialChildSize: _minSheetSize,
      minChildSize: _minSheetSize,
      maxChildSize: _maxSheetSize,
      snap: true,
      snapSizes: const [_minSheetSize, _maxSheetSize],
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(_scale(context, figmaTopRadius))),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurValue!, sigmaY: blurValue),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    gradientStartColor!,
                    const Color.fromRGBO(0, 0, 0, 0.6)
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(_scale(context, figmaTopRadius))),
                border: Border.all(
                    color: const Color.fromRGBO(102, 102, 102, 0.70),
                    width: 1.0),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(
                    _scale(context, 40),
                    _scale(context, 24),
                    _scale(context, 40),
                    bottomPadding + _scale(context, 160)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: _scale(context, 80),
                        height: _scale(context, 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(_scale(context, 4)),
                        ),
                      ),
                    ),
                    SizedBox(height: _scale(context, 24)),
                    _buildTitleAndPrice(context),
                    SizedBox(height: _scale(context, 60)),
                    Opacity(
                      opacity: clampedProgress,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '用户返图',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _scale(context, 41),
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(0, -_scale(context, 100.0)),
                            child: _buildUserShowcase(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleAndPrice(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _packageName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _scale(context, 47),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: _scale(context, 16)),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/ic_currency_diamond.png',
                  width: _scale(context, 40),
                  height: _scale(context, 40),
                ),
                SizedBox(width: _scale(context, 8)),
                Text(
                  _packagePrice,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "DIN Alternate",
                    fontSize: _scale(context, 47),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: _scale(context, 8)),
        Text(
          '萌宠日常 | 8.8万用户已使用',
          style: TextStyle(
            color: Colors.white,
            fontFamily: "PingFang SC",
            fontSize: _scale(context, 24),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildUserShowcase() {
    return MasonryGridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _userShowcaseImages.length,
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemBuilder: (context, index) {
        final imagePath = _userShowcaseImages[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImageViewer(imagePath: imagePath),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton(BuildContext context,
      {required VoidCallback onPressed}) {
    // --- 优化：拍摄信息确认时隐藏底边栏 ---
    if (_isCreationFlowOpen) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Center(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: _scale(context, 32)),
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                width: _scale(context, 373.1),
                height: _scale(context, 88.94),
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.6),
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.6)
                    ],
                    stops: const [0.0, 0.35, 0.69, 1.0],
                  ),
                  shape: const StadiumBorder(),
                ),
                child: Padding(
                  padding: EdgeInsets.all(_scale(context, 1.0)),
                  child: Container(
                    decoration: const ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-0.14, -1.0),
                        end: Alignment(0.14, 1.0),
                        colors: [
                          Color.fromRGBO(255, 255, 255, 0.2),
                          Color.fromRGBO(255, 255, 255, 0.4),
                          Color.fromRGBO(255, 255, 255, 0.1)
                        ],
                        stops: [0.0, 0.48, 0.97],
                      ),
                      shape: StadiumBorder(),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/ic_home_1.png',
                            width: _scale(context, 48),
                            height: _scale(context, 48),
                          ),
                          SizedBox(width: _scale(context, 16)),
                          Text(
                            '拍同款',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontSize: _scale(context, 34),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
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

// --- 新增功能: 全屏图片查看器 ---
class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;

  const FullScreenImageViewer({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// --- Creation Flow BottomSheet Widget (REFACTORED BASED ON FIGMA V5 - ENHANCED UX) ---
class _CreationFlowSheet extends StatefulWidget {
  final String packageName;
  final String packagePrice;
  final VoidCallback onClose;

  const _CreationFlowSheet({
    required this.packageName,
    required this.packagePrice,
    required this.onClose,
  });

  @override
  _CreationFlowSheetState createState() => _CreationFlowSheetState();
}

class _CreationFlowSheetState extends State<_CreationFlowSheet> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final bool _showHumanSelection = true;
  bool _isNextButtonPressed = false;

  String _selectedPet = '黑八';
  String _selectedHuman = '大美女';
  String _selectedRatio = '4:3';
  final List<String> _selectedDiy = ['wink', '伸舌头'];
  String _selectedStyle = '立绘插画';

  final List<String> _pets = ['黑八', '小金'];
  final List<String> _humans = ['大美女', '大帅哥'];
  final List<String> _ratios = [
    '1:1', '4:3', '3:4', '16:9', '9:16', '2:1', '1:2', '3:2'
  ];
  final List<String> _diyOptions = ['wink', '伸舌头', '趴着', '坐姿', '揣手', '握手'];
  final List<Map<String, String>> _styles = [
    {'name': '写实摄影', 'image': 'assets/images/cat1.jpg'},
    {'name': '精美手绘', 'image': 'assets/images/cat2.jpg'},
    {'name': '立绘插画', 'image': 'assets/images/cat3.jpg'},
    {'name': '美式涂鸦', 'image': 'assets/images/cat4.jpg'},
    {'name': '复古油画', 'image': 'assets/images/cat5.jpg'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double _scale(BuildContext context, double figmaValue) {
    return figmaValue * (MediaQuery.of(context).size.width / 750.0);
  }

  void _nextPage() {
    if (_currentStep >= 3) return;
    _pageController.animateToPage(
      _currentStep + 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    if (_currentStep <= 0) return;
    _pageController.animateToPage(
      _currentStep - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = _showHumanSelection ? 0.65 : 0.55;

    return Container(
      height: MediaQuery.of(context).size.height * sheetHeight,
      clipBehavior: Clip.antiAlias, // 确保圆角裁切生效
      decoration: BoxDecoration(
        // --- 任务2: 修改背景图使其自身透明 ---
        image: DecorationImage(
          image: const AssetImage('assets/images/bg_create_step.png'),
          fit: BoxFit.cover,
          // --- 自定义区域 ---
          // 直接控制背景图片本身的不透明度。
          // 1.0 表示完全不透明（原始图片），0.0 表示完全透明。
          // 您可以调整下面的 0.5 来改变背景的明暗程度。
          opacity: 0.8,
        ),
        // 原有的通过渐变叠加控制暗度的方法已被移除。
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentStep = page),
        children: [
          _buildInfoConfirmationStep(),
          _buildDiyContentStep(),
          _buildStyleSelectionStep(),
          _buildFinalConfirmationStep(),
        ],
      ),
    );
  }

  Widget _buildInfoConfirmationStep() {
    return _buildStepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: _scale(context, 70.0)),
            child: _buildSectionHeader('拍摄信息确认', '更直观更快捷选择喜欢的风格'),
          ),
          SizedBox(height: _scale(context, 48)),
          _buildChoiceSection(
            title: '选择宠物',
            options: _pets,
            currentValue: _selectedPet,
            onSelect: (v) => setState(() => _selectedPet = v),
          ),
          if (_showHumanSelection) ...[
            SizedBox(height: _scale(context, 48)),
            _buildChoiceSection(
              title: '选择人像',
              options: _humans,
              currentValue: _selectedHuman,
              onSelect: (v) => setState(() => _selectedHuman = v),
            ),
          ],
          SizedBox(height: _scale(context, 48)),
          _buildRatioSelectionList(),
        ],
      ),
      onNext: _nextPage,
    );
  }

  Widget _buildDiyContentStep() {
    // 静态标签数据
    final List<String> envTags = [
      '温馨的壁炉旁', '洒满阳光的窗台', '舒适的沙发上', '蓬松的地毯上', '被鲜花包围', '泡泡浴缸中', '艺术画廊中', '复古书房中'
    ];
    final List<String> itemTags = [
      '墨镜', '花环', '蝴蝶结领结', '小丝巾', '生日帽', '皇冠', '珍珠项链', '毛线帽', '草帽', '天使光环'
    ];
    final List<String> actionTags = [
      '歪头杀', '微笑', '眨眼', '吐舌头', '打哈气', '好奇的看着你'
    ];

    return _DiyContentStep(
      envTags: envTags,
      itemTags: itemTags,
      actionTags: actionTags,
      onNext: _nextPage,
    );
  }

  Widget _buildStyleSelectionStep() {
    return _buildStepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: _scale(context, 70.0)),
            child: _buildSectionHeader('画风选择', '自选喜欢的画面风格'),
          ),
          const SizedBox(height: 24),
        ],
      ),
      onNext: _nextPage,
    );
  }

  Widget _buildFinalConfirmationStep() {
    return _buildStepWrapper(
      showNextButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: _scale(context, 70.0)),
            child: _buildSectionHeader('拍摄确认', ''),
          ),
        ],
      ),
      centerWidget: FloatingActionButton(
        onPressed: () {
          widget.onClose(); // 调用父组件的onClose回调
          Navigator.pop(context); // 关闭弹窗
        },
        backgroundColor: const Color(0xFF7A5CFA),
        child: const Text('生成',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- 辅助组件 (Helper Widgets) ---

  Widget _buildStepWrapper({
    required Widget child,
    VoidCallback? onNext,
    bool showNextButton = true,
    Widget? centerWidget,
  }) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: _scale(context, 40)),
                child: child,
              ),
            ),
            _buildProgressIndicator(),
            SizedBox(height: _scale(context, 20)),
            Padding(
              padding: EdgeInsets.only(
                left: _scale(context, 40),
                right: _scale(context, 40),
                bottom: _scale(context, 40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (centerWidget != null) centerWidget,
                  if (showNextButton && centerWidget == null)
                    _buildNextButton(onPressed: onNext),
                ],
              ),
            )
          ],
        ),
        // --- 新增：关闭按钮 ---
        Positioned(
          top: _scale(context, 70.0) + _scale(context, 20), // 与标题文字居中对齐
          right: _scale(context, 20),
          child: Container(
            height: _scale(context, 34 * 1.2), // 与标题文字高度一致
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () {
                widget.onClose(); // 调用父组件的onClose回调
                Navigator.pop(context); // 关闭弹窗
              },
            ),
          ),
        ),
        if (_currentStep > 0)
          Positioned(
            top: _scale(context, 20),
            left: _scale(context, 20),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
              onPressed: _previousPage,
            ),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _scale(context, 80), vertical: _scale(context, 20)),
      child: Row(
        children: List.generate(4, (index) {
          final bool isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: _scale(context, 6)),
              height: _scale(context, 8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFD5B2FF)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(_scale(context, 4)),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNextButton({required VoidCallback? onPressed}) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isNextButtonPressed = true),
      onTapUp: (_) {
        setState(() => _isNextButtonPressed = false);
        Future.delayed(const Duration(milliseconds: 150), () {
          onPressed?.call();
        });
      },
      onTapCancel: () => setState(() => _isNextButtonPressed = false),
      child: AnimatedScale(
        scale: _isNextButtonPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/button_create_step.png',
              width: _scale(context, 542),
              height: _scale(context, 90),
              fit: BoxFit.contain,
            ),
            AnimatedOpacity(
              opacity: _isNextButtonPressed ? 0.7 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/ic_home_1.png',
                      width: _scale(context, 48), height: _scale(context, 48)),
                  SizedBox(width: _scale(context, 16)),
                  Text(
                    '下一步',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PingFang SC',
                      fontSize: _scale(context, 34),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: Colors.white,
                fontFamily: "PingFang SC",
                fontSize: _scale(context, 34 * 1.2),
                fontWeight: FontWeight.w400)),
        if (subtitle.isNotEmpty) ...[
          SizedBox(height: _scale(context, 8)),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontFamily: "PingFang SC",
                  fontSize: _scale(context, 21 * 1.2),
                  fontWeight: FontWeight.w400)),
        ]
      ],
    );
  }

  Widget _buildRatioSelectionList() {
    final double itemBaseHeight = _scale(context, 62 * 1.2 * 1.3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("选择比例",
            style: TextStyle(
                color: const Color(0xFFD5B2FF),
                fontFamily: "Inter",
                fontSize: _scale(context, 21 * 1.2),
                fontWeight: FontWeight.w400)),
        SizedBox(height: _scale(context, 24)),
        SizedBox(
          height: itemBaseHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _ratios.length,
            itemBuilder: (context, index) {
              final ratio = _ratios[index];
              final isSelected = _selectedRatio == ratio;
              return _buildRatioItem(ratio, isSelected, itemBaseHeight, (v) {
                setState(() => _selectedRatio = v);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRatioItem(String label, bool isSelected, double height,
      Function(String) onSelect) {
    final parts = label.split(':');
    final w = double.tryParse(parts[0]) ?? 1.0;
    final h = double.tryParse(parts[1]) ?? 1.0;
    final width = height * (w / h);
    return GestureDetector(
      onTap: () => onSelect(label),
      child: Padding(
        padding: EdgeInsets.only(right: _scale(context, 24)),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_scale(context, 8)),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFD5B2FF)
                  : Colors.white.withOpacity(0.4),
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                fontSize: _scale(context, 24 * 1.2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceSection({
    required String title,
    required List<String> options,
    required dynamic currentValue,
    required Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: const Color(0xFFD5B2FF),
                fontFamily: "Inter",
                fontSize: _scale(context, 21 * 1.2),
                fontWeight: FontWeight.w400)),
        SizedBox(height: _scale(context, 24)),
        Wrap(
          spacing: _scale(context, 35),
          runSpacing: _scale(context, 24),
          children: options.map((option) {
            final isSelected = currentValue == option;
            return _buildCircle(option, isSelected, onSelect);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCircle(
      String label, bool isSelected, Function(String) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(label),
      child: Column(
        children: [
          Container(
            width: _scale(context, 74.5 * 1.2),
            height: _scale(context, 74.5 * 1.2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: const Color(0xFFD5B2FF), width: _scale(context, 5))
                  : null,
            ),
          ),
          SizedBox(height: _scale(context, 16)),
          Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: _scale(context, 21 * 1.2),
                  fontFamily: "PingFang SC")),
        ],
      ),
    );
  }
}

// 新增 DIY内容页组件
class _DiyContentStep extends StatefulWidget {
  final List<String> envTags;
  final List<String> itemTags;
  final List<String> actionTags;
  final VoidCallback onNext;
  const _DiyContentStep({
    required this.envTags,
    required this.itemTags,
    required this.actionTags,
    required this.onNext,
  });
  @override
  State<_DiyContentStep> createState() => _DiyContentStepState();
}

class _DiyContentStepState extends State<_DiyContentStep> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _customTags = [];
  final Set<String> _selectedTags = {};
  String? _errorText;

  double _scale(BuildContext context, double figmaValue) {
    return figmaValue * (MediaQuery.of(context).size.width / 750.0);
  }

  void _tryAddCustomTag() {
    String text = _controller.text.trim();
    if (text.isEmpty) return;
    if (text.length > 10) text = text.substring(0, 10);
    if (_selectedTags.length >= 3) {
      setState(() {
        _errorText = '最多选择3个';
      });
      return;
    }
    if (_customTags.contains(text)) {
      setState(() {
        _errorText = '已添加';
      });
      return;
    }
    setState(() {
      _customTags.insert(0, text);
      _selectedTags.add(text);
      _controller.clear();
      _errorText = null;
    });
    _focusNode.unfocus();
  }

  void _onTagTap(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
        _errorText = null;
      } else {
        if (_selectedTags.length >= 3) {
          _errorText = '最多选择3个';
        } else {
          _selectedTags.add(tag);
          _errorText = null;
        }
      }
    });
  }

  Widget _buildInputField() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: _scale(context, 47.27),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-1, 0), end: Alignment(1, 0),
                colors: [
                  Color.fromRGBO(255,255,255,0.20),
                  Color.fromRGBO(255,255,255,0.10),
                  Color.fromRGBO(255,255,255,0.10),
                  Color.fromRGBO(255,255,255,0.20),
                ],
                stops: [0, 0.34, 0.69, 1],
              ),
              borderRadius: BorderRadius.circular(_scale(context, 24)),
              border: Border.all(
                color: const Color.fromRGBO(255,255,255,0.40),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLength: 10,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontSize: _scale(context, 18),
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '或输入自定义内容，回车添加',
                hintStyle: TextStyle(
                  color: const Color(0xFFB2B2B2),
                  fontFamily: 'Inter',
                  fontSize: _scale(context, 18),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: _scale(context, 20)),
              ),
              onSubmitted: (_) => _tryAddCustomTag(),
              onChanged: (_) {
                setState(() {
                  _errorText = null;
                });
              },
            ),
          ),
        ),
        SizedBox(width: _scale(context, 16)),
        GestureDetector(
          onTap: _tryAddCustomTag,
          child: Container(
            width: _scale(context, 120),
            height: _scale(context, 47.27),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-1, 0), end: Alignment(1, 0),
                colors: [
                  Color.fromRGBO(255,255,255,0.20),
                  Color.fromRGBO(255,255,255,0.10),
                  Color.fromRGBO(255,255,255,0.10),
                  Color.fromRGBO(255,255,255,0.20),
                ],
                stops: [0, 0.34, 0.69, 1],
              ),
              borderRadius: BorderRadius.circular(_scale(context, 24)),
              border: Border.all(
                color: const Color.fromRGBO(255,255,255,0.40),
                width: 1,
              ),
            ),
            child: Text('添加',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontSize: _scale(context, 18),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroup(String title, List<String> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: TextStyle(
            color: const Color(0xFFD5B2FF),
            fontFamily: 'Inter',
            fontSize: _scale(context, 21),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: _scale(context, 20)),
        Wrap(
          spacing: _scale(context, 20),
          runSpacing: _scale(context, 16),
          children: [
            ..._customTags.map((tag) => _buildTag(tag, true)),
            ...tags.map((tag) => _buildTag(tag, false)),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String tag, bool isCustom) {
    final bool selected = _selectedTags.contains(tag);
    return GestureDetector(
      onTap: () => _onTagTap(tag),
      child: Container(
        constraints: BoxConstraints(
          minWidth: _scale(context, 80),
          maxWidth: _scale(context, 180),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: _scale(context, 24),
          vertical: _scale(context, 10),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-1, 0), end: Alignment(1, 0),
            colors: [
              Color.fromRGBO(255,255,255,0.20),
              Color.fromRGBO(255,255,255,0.10),
              Color.fromRGBO(255,255,255,0.10),
              Color.fromRGBO(255,255,255,0.20),
            ],
            stops: [0, 0.34, 0.69, 1],
          ),
          borderRadius: BorderRadius.circular(_scale(context, 24)),
          border: Border.all(
            color: selected ? const Color(0xFFD5B2FF) : const Color.fromRGBO(255,255,255,0.40),
            width: 1.5,
          ),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontSize: _scale(context, 18),
            fontWeight: FontWeight.w400,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // 提取包装方法，静态辅助，传 context
  static Widget buildStepWrapper({
    required BuildContext context,
    required Widget child,
    VoidCallback? onNext,
    bool showNextButton = true,
    Widget? centerWidget,
  }) {
    // 直接复用 _CreationFlowSheetState 的 _buildStepWrapper 逻辑
    double _scale(BuildContext context, double figmaValue) {
      return figmaValue * (MediaQuery.of(context).size.width / 750.0);
    }
    final _CreationFlowSheetState? parent = context.findAncestorStateOfType<_CreationFlowSheetState>();
    final int? currentStep = parent?._currentStep;
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: _scale(context, 40)),
                child: child,
              ),
            ),
            if (parent != null) parent._buildProgressIndicator(),
            SizedBox(height: _scale(context, 20)),
            Padding(
              padding: EdgeInsets.only(
                left: _scale(context, 40),
                right: _scale(context, 40),
                bottom: _scale(context, 40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (centerWidget != null) centerWidget,
                  if (showNextButton && centerWidget == null)
                    parent != null ? parent._buildNextButton(onPressed: onNext) : const SizedBox.shrink(),
                ],
              ),
            )
          ],
        ),
        // --- 新增：关闭按钮 ---
        Positioned(
          top: _scale(context, 70.0) + _scale(context, 20),
          right: _scale(context, 20),
          child: Container(
            height: _scale(context, 34 * 1.2),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () {
                if (parent != null) {
                  parent.widget.onClose();
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ),
        if (parent != null && currentStep != null && currentStep > 0)
          Positioned(
            top: _scale(context, 20),
            left: _scale(context, 20),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
              onPressed: parent._previousPage,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildStepWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: _scale(context, 70.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DIY内容',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Inter",
                    fontSize: _scale(context, 34),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: _scale(context, 8)),
                Text('自选喜欢的画面内容',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Inter",
                    fontSize: _scale(context, 21),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: _scale(context, 32)),
          _buildInputField(),
          if (_errorText != null) ...[
            SizedBox(height: _scale(context, 8)),
            Text(_errorText!, style: TextStyle(color: Colors.red, fontSize: _scale(context, 18))),
          ],
          SizedBox(height: _scale(context, 32)),
          _buildGroup('环境', widget.envTags),
          SizedBox(height: _scale(context, 32)),
          _buildGroup('物品', widget.itemTags),
          SizedBox(height: _scale(context, 32)),
          _buildGroup('动作', widget.actionTags),
        ],
      ),
      onNext: widget.onNext,
    );
  }
}