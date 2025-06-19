// lib/viewmodels/home_flow_viewmodel.dart

import 'package:flutter/material.dart';

class HomeFlowViewModel extends ChangeNotifier {
  // 创建一个 PageController
  final PageController pageController = PageController();

  // 提供一个重置到 IntroPage 的方法
  void resetToIntro() {
    // 检查 controller 是否已附加到 PageView
    if (pageController.hasClients) {
      // 动画地滚动到第 0 页
      pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  // 在 ViewModel 被销毁时，也销毁 PageController
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
