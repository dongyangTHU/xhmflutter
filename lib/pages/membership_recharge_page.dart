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

  // --- 主要改动 1: 数据模型化 ---
  // 将套餐数据结构化，便于管理和渲染
  int _selectedPlanIndex = 1; // 默认选中月卡
  final List<Map<String, dynamic>> _plans = [
    {
      'title': '连续周卡',
      'price': '¥19.9',
      'originalPrice': '¥79.9',
      'paymentText': '¥19.9/周',
      'discount': '限时立减 ¥60',
      'benefits': [
        '连续周卡-连续周卡',
        '连续周卡-连续周卡',
        '连续周卡-连续周卡',
        '连续周卡-连续周卡',
        '连续周卡-连续周卡',
        '连续周卡-连续周卡',
      ]
    },
    {
      'title': '连续月卡',
      'price': '¥39.9',
      'originalPrice': '¥179.9',
      'paymentText': '¥39.9/月',
      'discount': '限时立减 ¥140',
      'benefits': [
        '·连续周卡-连续周卡',
        '·连续周卡-连续周卡',
        '·连续周卡-连续周卡',
        '·连续周卡-连续周卡',
        '·连续周卡-连续周卡',
        '·连续周卡-连续周卡',
      ]
    },
    {
      'title': '连续季卡',
      'price': '¥99.9',
      'originalPrice': '¥239.9',
      'paymentText': '¥99.9/季',
      'discount': '限时立减 ¥140',
      'benefits': [
        '·连续周卡-连续周卡',
        '·连续周卡-连续周卡',
        '·连续周卡-连续周卡',
        '·连续周卡-连续周卡',
        '·连续周卡-连续周卡',
        '·连续周卡-连续周卡',
      ]
    },
  ];

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
        physics: const NeverScrollableScrollPhysics(), // 禁止左右滑动切换 Tab
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
    // --- 主要改动 2: 动态更新支付栏 ---
    // 根据当前选中的套餐，获取支付栏需要显示的价格
    final selectedPlanPaymentText = _plans[_selectedPlanIndex]['paymentText'];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildBannerAndSelectorStack(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: _buildPricingSection(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomPayBar(
        selectedPlanPaymentText, // 使用动态价格
        '支付即同意《会员协议》', // 更新副标题
      ),
    );
  }

  Widget _buildBannerAndSelectorStack() {
    final pageViewKey = ValueKey<int>(_selectedPrivilegeIndex);
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
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
              final images = _moduleBannerImages[_selectedPrivilegeIndex];
              if (images.isEmpty) return Container(color: Colors.grey);
              return Image.asset(
                images[index % images.length],
                fit: BoxFit.cover,
              );
            },
          ),
        ),
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
              color: isSelected ? Colors.white : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // --- 主要改动 3: 重构价格版块 ---
  Widget _buildPricingSection() {
    final selectedPlanDiscount = _plans[_selectedPlanIndex]['discount'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('精选会员',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xffE4B07A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(selectedPlanDiscount,
                    style: const TextStyle(
                        color: Color(0xff522E17),
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('兑换会员 >',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          // 使用 IntrinsicHeight 确保 Row 内的卡片高度一致
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(_plans.length, (index) {
                bool isSelected = _selectedPlanIndex == index;
                // 使用 Expanded 和 flex 实现动态宽度
                return Expanded(
                  flex: isSelected ? 4 : 3, // 选中时 flex 更大
                  child: _buildPricingCard(
                    plan: _plans[index],
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedPlanIndex = index),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // --- 主要改动 4: 重构价格卡片 ---
  Widget _buildPricingCard({
    required Map<String, dynamic> plan,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // 根据选中状态定义不同的背景渐变
    final gradient = isSelected
        ? const LinearGradient(
            colors: [Color(0xff434574), Color(0xff2e3054)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0x0027294D), Color(0x0027294D)],
          );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected
                  ? const Color(0xff4d5082)
                  : Colors.white.withOpacity(0.1),
              width: 1),
          gradient: gradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan['title'],
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 8),
            Text(plan['price'],
                style: const TextStyle(
                    color: Color(0xffE4B07A),
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(plan['originalPrice'],
                  style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough)),
            ],
            const Spacer(),
            // 使用 AnimatedOpacity 实现权益列表的淡入淡出
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: isSelected
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (plan['benefits'] as List<String>)
                          .map((benefit) => _buildBenefitPoint(benefit))
                          .toList(),
                    )
                  : const SizedBox.shrink(), // 未选中时，不占空间
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.circle, color: Color(0xffE4B07A), size: 5),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // --- “冻干”标签页的构建方法 (无改动) ---
  Widget _buildFreezeDriedTab(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
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

  // --- 底部支付栏 (无改动) ---
  Widget _buildBottomPayBar(String price, String subtitle) {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: _scaffoldBgColor,
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
              const SizedBox(height: 4),
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
