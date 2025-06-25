// lib/pages/home_flow_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_flow_viewmodel.dart';
import 'intro_page.dart';
import 'home_page.dart';

class HomeFlowPage extends StatelessWidget {
  const HomeFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 从 Provider 获取控制页面上下滑动的 ViewModel
    final homeFlowViewModel = context.watch<HomeFlowViewModel>();

    // 直接返回PageView，不再需要ChangeNotifierProvider
    return PageView(
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
