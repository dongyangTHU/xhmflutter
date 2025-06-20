// lib/pages/membership_recharge_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';

class MembershipRechargePage extends StatefulWidget {
  const MembershipRechargePage({super.key});

  @override
  State<MembershipRechargePage> createState() => _MembershipRechargePageState();
}

class _MembershipRechargePageState extends State<MembershipRechargePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _bannerPageController;
  Timer? _bannerTimer;

  int _selectedPrivilegeIndex = 0;
  int _currentBannerSubIndex = 0;

  final List<List<String>> _moduleBannerImages = [
    [
      'assets/images/cat1.jpg',
      'assets/images/cat2.jpg',
      'assets/images/cat3.jpg'
    ],
    ['assets/images/cat4.jpg', 'assets/images/cat5.jpg'],
    [
      'assets/images/cat6.jpg',
      'assets/images/cat7.jpg',
      'assets/images/cat8.jpg'
    ],
    ['assets/images/cat9.jpg'],
  ];
  final List<String> _privilegeLabels = ['数字形象', '优先生成', '写真底图', '每日冻干'];
  int _selectedPlanIndex = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bannerPageController = PageController();
    _startBannerTimer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bannerPageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_bannerPageController.hasClients) return;

      List<String> currentModuleImages =
          _moduleBannerImages[_selectedPrivilegeIndex];
      int nextSubIndex = _currentBannerSubIndex + 1;

      if (nextSubIndex >= currentModuleImages.length) {
        int nextModuleIndex =
            (_selectedPrivilegeIndex + 1) % _moduleBannerImages.length;

        if (mounted) {
          setState(() {
            _selectedPrivilegeIndex = nextModuleIndex;
            _currentBannerSubIndex = 0;
          });
        }

        _bannerPageController.jumpToPage(0);
      } else {
        if (mounted) {
          setState(() {
            _currentBannerSubIndex = nextSubIndex;
          });
        }
        _bannerPageController.animateToPage(
          _currentBannerSubIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  static const Color _primaryColor = Color(0xFF7A5CFA);
  static const Color _scaffoldBgColor = Color(0xFF1A182E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMembershipTab(context),
          _buildFreezeDriedTab(context),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: _primaryColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(text: '会员'),
          Tab(text: '冻干'),
        ],
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () {},
          child: const Text(
            '充值记录',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // --- “会员”页面的构建方法 ---
  Widget _buildMembershipTab(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // 1. 顶部 Banner 和选择条区域（固定高度，不滚动）
          _buildBannerAndSelectorStack(),
          // 2. 下方的可滚动内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildPricingSection(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomPayBar('¥39.9/月', '含xx元优惠(会员价)'),
    );
  }

  // 将 Banner 和选择条包裹在 Stack 中以实现叠加
  Widget _buildBannerAndSelectorStack() {
    // 使用 Key 来确保在模块切换时 PageView 被正确地重建
    final pageViewKey = ValueKey<int>(_selectedPrivilegeIndex);

    return Stack(
      children: [
        // 背景图片 Banner
        SizedBox(
          width: double.infinity,
          height: 250,
          child: PageView.builder(
            key: pageViewKey,
            controller: _bannerPageController,
            itemCount: _moduleBannerImages[_selectedPrivilegeIndex].length,
            onPageChanged: (page) {
              setState(() {
                _currentBannerSubIndex = page;
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                _moduleBannerImages[_selectedPrivilegeIndex][index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        // 定位在底部的磨砂玻璃选择条
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildPrivilegeSelectorBar(),
        ),
      ],
    );
  }

  Widget _buildPrivilegeSelectorBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: 60,
          color: Colors.black.withOpacity(0.25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _privilegeLabels.length,
              (index) => _buildSelectorItem(index, _privilegeLabels[index]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorItem(int index, String label) {
    bool isSelected = _selectedPrivilegeIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedPrivilegeIndex == index) return;
        setState(() {
          _selectedPrivilegeIndex = index;
          _currentBannerSubIndex = 0;
        });
        _bannerPageController.jumpToPage(0);
        _startBannerTimer();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? _primaryColor : Colors.transparent,
              width: 3.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('精选会员',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('兑换会员 >',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        const Text('限时立减 ¥60',
            style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildPricingCard('连续包周', '¥19.9', 0),
            const SizedBox(width: 12),
            _buildPricingCard('连续包月', '¥39.9', 1),
            const SizedBox(width: 12),
            _buildPricingCard('年费', '¥99.9', 2),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingCard(String title, String price, int index) {
    bool isSelected = _selectedPlanIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPlanIndex = index),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? _primaryColor : Colors.transparent,
                width: 2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF3A307B).withOpacity(0.5),
                const Color(0xFF2B2361).withOpacity(0.5),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(price,
                  style: const TextStyle(
                      color: _primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              _buildBenefitPoint('专属数字形象'),
              _buildBenefitPoint('作品优先生成'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: _primaryColor, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // --- “冻干”标签页的构建方法 ---
  Widget _buildFreezeDriedTab(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        // 为 AppBar 和状态栏预留空间
        padding: EdgeInsets.only(
            top: kToolbarHeight + MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
            bottom: 24),
        child: Column(
          children: [
            _buildSnapetCard(),
            const SizedBox(height: 24),
            _buildFreezeDriedSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomPayBar('¥ 20', '首充双倍已生效, 立即获得200冻干'),
    );
  }

  Widget _buildSnapetCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3A307B).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Snapet Card', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('冻干数量',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              Row(
                children: const [
                  Icon(Icons.ac_unit, color: Colors.yellow, size: 24),
                  SizedBox(width: 8),
                  Text('01274992',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFreezeDriedSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('冻干充值',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('兑换冻干 >',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            _buildRechargeOption('200', '100x2'),
            _buildRechargeOption('500', null),
            _buildRechargeOption('1000', null),
            _buildRechargeOption('5000', null),
            _buildRechargeOption('10000', null),
            _buildRechargeOption('自定义', null, isCustom: true),
          ],
        ),
        const SizedBox(height: 8),
        const Text('购买冻干立即即可体验',
            style: TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildRechargeOption(String amount, String? subtitle,
      {bool isCustom = false}) {
    return Container(
      decoration: BoxDecoration(
        color:
            isCustom ? Colors.white.withOpacity(0.08) : const Color(0xFFC9A87D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(amount,
              style: TextStyle(
                  color: isCustom ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    color: isCustom ? Colors.white70 : Colors.black54,
                    fontSize: 12)),
          ]
        ],
      ),
    );
  }

  Widget _buildBottomPayBar(String price, String subtitle) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _scaffoldBgColor.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(price,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text('立即支付',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
