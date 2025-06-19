// lib/pages/home_flow_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_flow_viewmodel.dart';
import 'intro_page.dart';
import 'home_page.dart';

// 不再需要 StatefulWidget
class HomeFlowPage extends StatelessWidget {
  const HomeFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- 关键修改 ---
    // 从 Provider 获取 ViewModel 实例
    final homeFlowViewModel = context.watch<HomeFlowViewModel>();

    return PageView(
      // 使用 ViewModel 中的 PageController
      controller: homeFlowViewModel.pageController,
      scrollDirection: Axis.vertical,
      physics: const ClampingScrollPhysics(),
      children: const [
        IntroPage(),
        HomePage(),
      ],
    );
  }
}
