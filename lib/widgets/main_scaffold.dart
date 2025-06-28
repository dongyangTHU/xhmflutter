// lib/widgets/main_scaffold.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_flow_viewmodel.dart';
import 'dart:ui';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/intro')) {
      return 0;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    // "相机" 页面是 push 的，不会常驻，因此不需要索引，默认返回首页索引
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.read<HomeFlowViewModel>().resetToIntro();
        context.go('/intro');
        break;
      case 1:
        context.push('/creation-store');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: child,
      bottomNavigationBar: _buildCustomBottomNavBar(context),
    );
  }

  /// 构建具有玻璃质感的自定义底部导航栏
  Widget _buildCustomBottomNavBar(BuildContext context) {
    const double blurAmount = 12.5;
    const Radius cornerRadius = Radius.circular(21.0);
    const BorderRadius borderRadius =
        BorderRadius.only(topLeft: cornerRadius, topRight: cornerRadius);
    const double backgroundOpacity = 0.1;

    // [核心优化 Part 1]
    // 给整个底部栏一个固定的高度。这是实现垂直居中的基础。
    // 你可以微调这个 `88.0` 来改变底部栏的整体高度，从而影响内容的居中效果。
    const double navBarHeight = 88.0;

    return Container(
      height: navBarHeight,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(backgroundOpacity),
              borderRadius: borderRadius,
            ),
            child: Stack(
              children: [
                // [核心优化 Part 2]
                // 使用 Center 组件将内容包裹起来。
                // Center 会将它的子组件（SafeArea -> Row）放置在父组件（Stack）的中央。
                Center(
                  child: SafeArea(
                    top: false, // 我们只需要底部的安全边距
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(context, 0, 'assets/images/ic_scaffold_1.png', '首页'),
                        _buildNavItem(context, 1, 'assets/images/ic_scaffold_2.png', '相机'),
                        _buildNavItem(context, 2, 'assets/images/ic_scaffold_3.png', '个人中心'),
                      ],
                    ),
                  ),
                ),
                
                // --- 顶部玻璃辉光效果 (保持不变) ---
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0, 0.8],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建导航栏的单个项目
  Widget _buildNavItem(
      BuildContext context, int index, String imagePath, String label) {
    final int selectedIndex = _calculateSelectedIndex(context);
    final bool isSelected = index == selectedIndex;
    final Color textColor = isSelected ? Colors.white : Colors.white70;
    final double imageOpacity = isSelected ? 1.0 : 0.7;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index, context),
        behavior: HitTestBehavior.opaque,
        // [核心优化 Part 3]
        // 移除了不必要的内部Container(height: 60), 让Column自然地被Center组件管理。
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 保持内容在Column内部垂直居中
          mainAxisSize: MainAxisSize.min, // 让Column的高度仅包裹其内容
          children: [
            Opacity(
              opacity: imageOpacity,
              child: Image.asset(
                imagePath,
                width: 28,
                height: 28,
                gaplessPlayback: true,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}