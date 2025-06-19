// lib/pages/membership_recharge_page.dart

import 'package:flutter/material.dart';

class MembershipRechargePage extends StatefulWidget {
  const MembershipRechargePage({super.key});

  @override
  State<MembershipRechargePage> createState() => _MembershipRechargePageState();
}

class _MembershipRechargePageState extends State<MembershipRechargePage> {
  int _selectedPlanIndex = 1;

  static const Color _primaryColor = Color(0xFF7A5CFA);
  static const Color _scaffoldBgColor = Color(0xFF1A182E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildUserInfoSection(),
              const SizedBox(height: 24),
              _buildQuantumBanner(),
              const SizedBox(height: 30),
              _buildFreezeDriedSection(),
              const SizedBox(height: 30),
              _buildMembershipPrivilegesSection(),
              const SizedBox(height: 30),
              _buildPricingSection(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomPayBar(),
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
        '会员中心',
        style: TextStyle(color: Colors.white, fontSize: 18),
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

  Widget _buildUserInfoSection() {
    return Row(
      children: [
        const CircleAvatar(radius: 28, backgroundColor: Colors.white24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '黑八宝宝',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '2025/06/15到期-年卡会员',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantumBanner() {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Quantum',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildFreezeDriedSection() {
    return Column(
      children: [
        _buildSectionHeader('冻干充值', '兑换冻干'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _buildRechargeOption('100'),
            _buildRechargeOption('500'),
            _buildRechargeOption('1000'),
            _buildRechargeOption('5000'),
            _buildRechargeOption('10000'),
            _buildRechargeOption('自定义', isCustom: true),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '购买冻干不赠送额外权益',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRechargeOption(String amount, {bool isCustom = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isCustom)
                // --- 关键修改：替换图标 ---
                const Icon(Icons.ac_unit, color: Colors.yellow, size: 16),
              const SizedBox(width: 4),
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipPrivilegesSection() {
    return Column(
      children: [
        _buildSectionHeader('精选会员', '兑换会员'),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildPrivilegeIcon(Icons.face_retouching_natural, '数字形象'),
            _buildPrivilegeIcon(Icons.star_border, '优先生成'),
            _buildPrivilegeIcon(Icons.pets, '优先绘制'),
            _buildPrivilegeIcon(Icons.collections, '写真无限'),
            _buildPrivilegeIcon(Icons.color_lens_outlined, '专属画板'),
            _buildPrivilegeIcon(Icons.sell_outlined, '超低价格'),
            _buildPrivilegeIcon(Icons.workspace_premium_outlined, '超低价格'),
            _buildPrivilegeIcon(Icons.workspace_premium, '超低价格'),
          ],
        ),
      ],
    );
  }

  Widget _buildPrivilegeIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white.withOpacity(0.1),
          child: Icon(icon, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (actionText.isNotEmpty)
          Text(
            '$actionText >',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      children: [
        _buildSectionHeader('限时立减 ¥60', ''),
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
        onTap: () {
          setState(() {
            _selectedPlanIndex = index;
          });
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _primaryColor : Colors.transparent,
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF3A307B).withOpacity(0.5),
                const Color(0xFF2B2361).withOpacity(0.5),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                    color: _primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildBenefitPoint(),
                _buildBenefitPoint(),
                _buildBenefitPoint(),
                _buildBenefitPoint(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitPoint() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: const [
          Icon(Icons.check_circle, color: _primaryColor, size: 14),
          SizedBox(width: 6),
          Text('连续周卡续订', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBottomPayBar() {
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
            children: const [
              Text(
                '¥39.9/月',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '含xx元优惠(会员价)',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text(
              '立即支付',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
