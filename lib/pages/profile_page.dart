// lib/pages/profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../viewmodels/profile_viewmodel.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 context.watch 监听 ProfileViewModel 的变化
    final profileViewModel = context.watch<ProfileViewModel>();

    return Container(
      color: const Color(0xff1c1b22),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Column(
          children: [
            // 将 viewModel 和它的方法传递给构建方法
            _buildWallpaperArea(context, profileViewModel),
            const SizedBox(height: 20),
            _buildMembershipCard(context), // 传入 context 以便导航
            const SizedBox(height: 30),
            _buildPetSection(),
            const SizedBox(height: 20),
            _buildOptionList(),
            const SizedBox(height: 30),
            _buildLogoutButton(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildWallpaperArea(BuildContext context, ProfileViewModel viewModel) {
    return GestureDetector(
      // 调用 ViewModel 中的方法
      onTap: () => viewModel.pickWallpaper(),
      child: SizedBox(
        height: 280,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              // 从 ViewModel 获取图片状态
              child: viewModel.wallpaperImage == null
                  ? Image.asset('assets/images/cat9.jpg', fit: BoxFit.cover)
                  : Image.file(viewModel.wallpaperImage!, fit: BoxFit.cover),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
            _buildHeaderContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 使用 GoRouter 进行页面跳转
        context.push('/membership-recharge');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3F7E).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '冻干数量',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  '会员剩余时长: 30天',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  '01274992',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '充值',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 其他构建方法保持不变 ---
  // 它们现在是 StatelessWidget 的一部分
  Widget _buildHeaderContent() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 45,
                backgroundImage: AssetImage('assets/images/256.png'),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              '尊敬的用户SW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 8.0, color: Colors.black54)],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '点击上方区域更换壁纸',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '我的宠物档案AI作品',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '管理宠物 >',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPetListItem(),
          _buildPetListItem(),
          _buildPetListItem(),
        ],
      ),
    );
  }

  Widget _buildPetListItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 24, backgroundColor: Colors.white24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('黑八宝宝', style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 4),
              Text(
                'Ta的AI照片集',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildOptionRow('邀请码'),
            _buildOptionRow('联系客服'),
            _buildOptionRow('APP主题'),
            _buildOptionRow('关于我们'),
            _buildOptionRow('意见反馈'),
            _buildOptionRow('账户与安全', showDivider: false),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(String title, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Divider(color: Colors.white.withOpacity(0.1), height: 1),
          ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.15),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {},
        child: const Text(
          '退出',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
