// lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/user_entity.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 来同时监听 UserViewModel 和 AuthViewModel
    return Consumer2<UserViewModel, AuthViewModel>(
      builder: (context, userViewModel, authViewModel, child) {
        return Container(
          color: const Color(0xff1c1b22),
          // 注意：现在登出按钮只需要authViewModel
          child: _buildBody(context, userViewModel, authViewModel),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, UserViewModel userViewModel,
      AuthViewModel authViewModel) {
    // 页面首次加载时，显示加载动画
    if (userViewModel.isLoading && userViewModel.userInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // 加载失败时，显示重试按钮
    if (userViewModel.error != null && userViewModel.userInfo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: ${userViewModel.error}',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => userViewModel.fetchUserInfo(),
              child: const Text('点击重试'),
            )
          ],
        ),
      );
    }

    // 如果userInfo为空，提供一个默认的空对象，防止UI报错
    final userInfo = userViewModel.userInfo ?? UserEntity();

    return RefreshIndicator(
      onRefresh: () => userViewModel.fetchUserInfo(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildWallpaperArea(context, userInfo),
            const SizedBox(height: 20),
            _buildMembershipCard(context, userInfo),
            const SizedBox(height: 30),
            _buildPetSection(),
            const SizedBox(height: 20),
            _buildOptionList(),
            const SizedBox(height: 30),
            // 将 authViewModel 传递给登出按钮
            _buildLogoutButton(context, authViewModel),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // --- 核心修改: _buildLogoutButton不再需要接收UserViewModel ---
  Widget _buildLogoutButton(BuildContext context, AuthViewModel authViewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.15),
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          // --- 核心修改: 调用新的logout方法，不再需要传入任何参数 ---
          authViewModel.logout();
        },
        child: const Text('退出',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ===================================================================
  // 以下是UI代码，无需修改
  // ===================================================================

  Widget _buildWallpaperArea(BuildContext context, UserEntity userInfo) {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/cat9.jpg', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.5)
                  ],
                ),
              ),
            ),
          ),
          _buildHeaderContent(userInfo),
        ],
      ),
    );
  }

  Widget _buildHeaderContent(UserEntity userInfo) {
    final bool hasAvatar = userInfo.avatar.isNotEmpty;
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
                      color: Colors.black.withOpacity(0.3), blurRadius: 10)
                ],
              ),
              child: CircleAvatar(
                radius: 45,
                backgroundImage: hasAvatar
                    ? NetworkImage(userInfo.avatar)
                    : const AssetImage('assets/images/256.png')
                        as ImageProvider,
                onBackgroundImageError: hasAvatar ? (_, __) {} : null,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              userInfo.nickName.isNotEmpty ? userInfo.nickName : "尊贵的用户",
              style: const TextStyle(
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
              child: const Text('欢迎回来',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipCard(BuildContext context, UserEntity userInfo) {
    return GestureDetector(
      onTap: () => context.push('/membership-recharge'),
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
              children: [
                const Text('冻干数量',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 4),
                Text('会员剩余时长: ${userInfo.remainingDays}天',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            Row(
              children: [
                Text(userInfo.balance,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('充值',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
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
            children: const [
              Text('我的宠物档案AI作品',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text('管理宠物 >',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
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
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: const [
          CircleAvatar(radius: 24, backgroundColor: Colors.white24),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('黑八宝宝', style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 4),
              Text('Ta的AI照片集',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
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
            borderRadius: BorderRadius.circular(12)),
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
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white54, size: 16),
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
}
