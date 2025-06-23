// lib/pages/package_detail_page.dart

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _bannerTimer;

  // --- 关键修改 1: 将套系信息定义为变量，方便传递 ---
  final String _packageName = '艺术相框名画';
  final String _packagePrice = '299';

  @override
  void initState() {
    super.initState();
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
      int nextPage = (_currentPage + 1) % _backgroundImages.length;
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
        // --- 关键修改 2: 将套系信息传递给 BottomSheet ---
        packageName: _packageName,
        packagePrice: _packagePrice,
      ),
    );
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
        actions: [_buildTopRightButton()],
      ),
      body: Stack(
        children: [
          _buildBackgroundSlider(),
          _buildDraggableInfoSheet(),
          _buildBottomButton(onPressed: _showCreationFlow),
        ],
      ),
    );
  }

  // --- Widgets for the main page ---
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
            Icon(Icons.ac_unit, color: Colors.yellow, size: 16),
            SizedBox(width: 4),
            Text('1502937',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
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
          onPageChanged: (page) => setState(() => _currentPage = page),
          itemBuilder: (context, index) => Image.asset(
            _backgroundImages[index],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
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
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
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
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTitleAndPrice(),
                    const SizedBox(height: 24),
                    const Text('用户照',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
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
          children: [
            Row(children: [
              Text(_packageName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Colors.yellow, size: 20),
            ]),
            Row(children: [
              const Icon(Icons.ac_unit, color: Colors.yellow, size: 20),
              const SizedBox(width: 4),
              Text(_packagePrice,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
        const SizedBox(height: 4),
        const Text('萌宠日常 | 8.8万用户已使用',
            style: TextStyle(color: Colors.white70, fontSize: 12)),
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
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(_userShowcaseImages[index], fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildBottomButton({required VoidCallback onPressed}) {
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
                    label: const Text('拍同款',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
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

// --- Creation Flow BottomSheet Widget ---
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

  // State for selections
  String _selectedPet = '黑八';
  String _selectedHuman = '大美女';
  String _selectedRatio = '4:3';
  final List<String> _selectedDiy = ['wink', '伸舌头'];
  String _selectedStyle = '立绘插画';

  // Data for options
  final List<String> _pets = ['黑八', '小金', '免费体验', '免费体验', '免费体验', '免费体验'];
  final List<String> _humans = ['大美女', '大帅哥'];
  final List<String> _ratios = [
    '1:1',
    '2:1',
    '1:2',
    '4:3',
    '3:4',
    '16:9',
    '9:16',
    '3:2'
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

  void _nextPage() {
    _pageController.animateToPage(
      _currentStep + 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.animateToPage(
      _currentStep - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF2C284E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildAppBar(),
          Expanded(
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
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentStep > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white70),
                  onPressed: _previousPage)
              : const SizedBox(width: 48),
          if (_currentStep < 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: const [
                  Icon(Icons.ac_unit, color: Colors.yellow, size: 14),
                  SizedBox(width: 4),
                  Text('1502937',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildInfoConfirmationStep() {
    return _buildStepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('拍摄信息确认', '更直观更快捷选择喜欢的风格'),
          const SizedBox(height: 24),
          _buildChoiceSection('选择宠物', _pets, _selectedPet,
              (v) => setState(() => _selectedPet = v)),
          const SizedBox(height: 24),
          _buildChoiceSection('选择人像', _humans, _selectedHuman,
              (v) => setState(() => _selectedHuman = v)),
          const SizedBox(height: 24),
          _buildChoiceSection('选择比例', _ratios, _selectedRatio,
              (v) => setState(() => _selectedRatio = v),
              isChip: true),
        ],
      ),
      onNext: _nextPage,
    );
  }

  Widget _buildDiyContentStep() {
    return _buildStepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('DIY内容', '自选喜欢的画面内容'),
          const SizedBox(height: 24),
          _buildChoiceSection('动作类', _diyOptions, _selectedDiy, (v) {
            setState(() {
              if (_selectedDiy.contains(v)) {
                _selectedDiy.remove(v);
              } else {
                _selectedDiy.add(v);
              }
            });
          }, isChip: true, isMultiSelect: true),
          const SizedBox(height: 16),
          const Text('配饰类',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 16),
          const Text('背景类',
              style: TextStyle(color: Colors.white, fontSize: 16)),
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
          _buildSectionHeader('画风选择', '自选喜欢的画面风格'),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _styles.length,
              itemBuilder: (context, index) {
                final style = _styles[index];
                final isSelected = _selectedStyle == style['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedStyle = style['name']!),
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF7A5CFA)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(style['image']!,
                                fit: BoxFit.cover, width: double.infinity),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(style['name']!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      onNext: _nextPage,
    );
  }

  // --- 关键修改 3: 使用动态数据构建最终确认步骤 ---
  Widget _buildFinalConfirmationStep() {
    return _buildStepWrapper(
      showNextButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('拍摄确认', ''),
          const SizedBox(height: 24),
          _buildConfirmationItem(
              '拍摄套系', widget.packageName), // 使用 widget.packageName
          _buildConfirmationItem('拍摄宠物', _selectedPet),
          _buildConfirmationItem('写真比例', _selectedRatio),
          _buildConfirmationItem('底片数量', '4'), // 保持静态，因为UI没有提供选项
          _buildConfirmationItem('拍摄画风', _selectedStyle),
          _buildConfirmationItem('DIY画面', _selectedDiy.join(', ')),
          const SizedBox(height: 20),
          _buildConfirmationItem('拍摄金额', widget.packagePrice,
              isPrice: true), // 使用 widget.packagePrice
          _buildConfirmationItem('账户余额', '100000000'), // 保持静态
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

  // --- Helper widgets ---
  Widget _buildStepWrapper(
      {required Widget child,
      VoidCallback? onNext,
      bool showNextButton = true,
      Widget? centerWidget}) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: child,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            mainAxisAlignment: centerWidget != null
                ? MainAxisAlignment.center
                : MainAxisAlignment.end,
            children: [
              if (centerWidget != null) centerWidget,
              if (showNextButton && centerWidget == null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_enhance_outlined,
                      color: Colors.white),
                  label: const Text('下一步',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A5CFA),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ]
      ],
    );
  }

  Widget _buildChoiceSection(String title, List<String> options,
      dynamic currentValue, Function(String) onSelect,
      {bool isChip = false, bool isMultiSelect = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = isMultiSelect
                ? (currentValue as List).contains(option)
                : currentValue == option;
            return isChip
                ? _buildChip(option, isSelected, onSelect)
                : _buildCircle(option, isSelected, onSelect);
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
          CircleAvatar(
            radius: 24,
            backgroundColor: isSelected
                ? const Color(0xFF7A5CFA)
                : Colors.white.withOpacity(0.1),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, Function(String) onSelect) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSelect(label),
      backgroundColor: Colors.white.withOpacity(0.1),
      selectedColor: const Color(0xFF7A5CFA),
      labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildConfirmationItem(String label, String value,
      {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              color: isPrice ? const Color(0xFF7A5CFA) : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
