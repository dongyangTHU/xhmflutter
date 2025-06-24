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
    // --- 关键修改: 监听 /intro 路径 ---
    if (location.startsWith('/intro')) {
      return 0;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    // 默认返回首页索引
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        // --- 关键修改: 跳转到 /intro ---
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
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: BottomNavigationBar(
            backgroundColor: Colors.black.withOpacity(0.3),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            currentIndex: _calculateSelectedIndex(context),
            onTap: (index) => _onItemTapped(index, context),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                label: '创作',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
            ],
          ),
        ),
      ),
    );
  }
}
