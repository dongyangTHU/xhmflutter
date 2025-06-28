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
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = _currentPage + 1;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showCreationFlow() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreationFlowSheet(
        packageName: _packageName,
        packagePrice: _packagePrice,
      ),
    );
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
            return Image.asset(
              _backgroundImages[realIndex],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
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

                    // --- 终极修复方案 第1步: 大幅缩减外部间距 ---
                    // 将这个主要的外部间距从 36 减小到 12
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
                              // 保持行高压缩，确保文本自身不产生额外间距
                              height: 1.0,
                            ),
                          ),
                          
                          // --- 终极修复方案 第2步: 使用 Transform.translate 进行视觉矫正 ---
                          // 这个小部件会将瀑布流向上强制移动一点距离，覆盖任何剩余的顽固间隙
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
        // --- 优化 2: 添加点击放大功能 ---
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
          // 点击屏幕任何地方返回
          Navigator.pop(context);
        },
        child: Center(
          child: Image.asset(
            imagePath,
            // fit: BoxFit.contain 可以完整显示图片，不会裁剪
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}




// ... 此处省略 _CreationFlowSheet 的代码，请确保你文件中的这部分代码保持不变 ...
// --- Creation Flow BottomSheet Widget (REFACTORED BASED ON FIGMA V4 - STACK LAYOUT) ---
class _CreationFlowSheet extends StatefulWidget {
  final String packageName;
  final String packagePrice;

  const _CreationFlowSheet({
    required this.packageName,
    required this.packagePrice,
  });

  @override
  _CreationFlowSheetState createState() => _CreationFlowSheetState();
}

class _CreationFlowSheetState extends State<_CreationFlowSheet> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final bool _showHumanSelection = true;

  String _selectedPet = '黑八';
  String _selectedHuman = '大美女';
  String _selectedRatio = '4:3';
  final List<String> _selectedDiy = ['wink', '伸舌头'];
  String _selectedStyle = '立绘插画';

  final List<String> _pets = ['黑八', '小金'];
  final List<String> _humans = ['大美女', '大帅哥'];
  
  // 您可以在此列表中直接修改、添加、删除或重新排序比例选项
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

  double _scale(double figmaValue) {
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg_create_step.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // --- 修改: 移除 Column 和 AppBar, 直接使用 PageView ---
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

  // AppBar 已被移除，其功能集成到 _buildStepWrapper 中

  Widget _buildInfoConfirmationStep() {
    return _buildStepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 修改: 使用 Padding 控制顶部距离，而非 Transform ---
          // 您可以安全地调整这里的 top 值来控制标题与上边缘的距离
          Padding(
            padding: EdgeInsets.only(top: _scale(60.0)),
            child: _buildSectionHeader('拍摄信息确认', '更直观更快捷选择喜欢的风格'),
          ),
          SizedBox(height: _scale(48)),
          _buildChoiceSection(
            title: '选择宠物',
            options: _pets,
            currentValue: _selectedPet,
            onSelect: (v) => setState(() => _selectedPet = v),
          ),
          if (_showHumanSelection) ...[
            SizedBox(height: _scale(35)),
            _buildChoiceSection(
              title: '选择人像',
              options: _humans,
              currentValue: _selectedHuman,
              onSelect: (v) => setState(() => _selectedHuman = v),
            ),
          ],
          SizedBox(height: _scale(35)),
          _buildRatioSelectionList(),
        ],
      ),
      onNext: _nextPage,
    );
  }
  
  // 其他步骤的构建方法也应使用新的 Wrapper 结构
  Widget _buildDiyContentStep() {
    return _buildStepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
         children: [
          Padding(
            padding: EdgeInsets.only(top: _scale(70.0)),
            child: _buildSectionHeader('DIY内容', '自选喜欢的画面内容'),
          ),
          const SizedBox(height: 24),
        ],
      ),
      onNext: _nextPage,
    );
  }

  Widget _buildStyleSelectionStep() {
    return _buildStepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
         children: [
          Padding(
            padding: EdgeInsets.only(top: _scale(70.0)),
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
            padding: EdgeInsets.only(top: _scale(70.0)),
            child: _buildSectionHeader('拍摄确认', ''),
          ),
        ],
      ),
      centerWidget: FloatingActionButton(
        onPressed: () => context.pop(),
        backgroundColor: const Color(0xFF7A5CFA),
        child: const Text('生成',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- 辅助组件 (Helper Widgets) ---

  // --- 修改: _buildStepWrapper 现在是布局的基石，包含 Stack ---
  Widget _buildStepWrapper({
    required Widget child,
    VoidCallback? onNext,
    bool showNextButton = true,
    Widget? centerWidget,
  }) {
    return Stack(
      children: [
        // 主要内容和底部按钮
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: _scale(40)),
                child: child,
              ),
            ),
            _buildProgressIndicator(),
            SizedBox(height: _scale(20)),
            Padding(
              padding: EdgeInsets.only(
                left: _scale(40),
                right: _scale(40),
                bottom: _scale(40),
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
        // 返回按钮，自由地放置在左上角
        if (_currentStep > 0)
          Positioned(
            top: _scale(20),
            left: _scale(20),
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
      padding: EdgeInsets.symmetric(horizontal: _scale(80), vertical: _scale(20)),
      child: Row(
        children: List.generate(4, (index) {
          final bool isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: _scale(6)),
              height: _scale(8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFD5B2FF)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(_scale(4)),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNextButton({required VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/button_create_step.png',
            width: _scale(542),
            height: _scale(90),
            fit: BoxFit.contain,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/ic_home_1.png',
                  width: _scale(48), height: _scale(48)),
              SizedBox(width: _scale(16)),
              Text(
                '下一步',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'PingFang SC',
                  fontSize: _scale(34),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
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
                fontSize: _scale(34 * 1.2),
                fontWeight: FontWeight.w400)),
        if (subtitle.isNotEmpty) ...[
          SizedBox(height: _scale(8)),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontFamily: "PingFang SC",
                  fontSize: _scale(21 * 1.2),
                  fontWeight: FontWeight.w400)),
        ]
      ],
    );
  }

  Widget _buildRatioSelectionList() {
    final double itemBaseHeight = _scale(62 * 1.2 * 1.3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("选择比例",
            style: TextStyle(
                color: const Color(0xFFD5B2FF),
                fontFamily: "Inter",
                fontSize: _scale(21 * 1.2),
                fontWeight: FontWeight.w400)),
        SizedBox(height: _scale(24)),
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
        padding: EdgeInsets.only(right: _scale(24)),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_scale(8)),
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
                fontSize: _scale(24 * 1.2),
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
                fontSize: _scale(21 * 1.2),
                fontWeight: FontWeight.w400)),
        SizedBox(height: _scale(24)),
        Wrap(
          spacing: _scale(35),
          runSpacing: _scale(24),
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
            width: _scale(74.5 * 1.2),
            height: _scale(74.5 * 1.2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: const Color(0xFFD5B2FF), width: _scale(5))
                  : null,
            ),
          ),
          SizedBox(height: _scale(16)),
          Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: _scale(21 * 1.2),
                  fontFamily: "PingFang SC")),
        ],
      ),
    );
  }
}