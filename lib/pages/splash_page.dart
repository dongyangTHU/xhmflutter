// lib/pages/splash_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // 启动页只负责触发验证，不负责导航
    // WidgetsBinding确保initState执行完毕后再调用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 直接调用AuthViewModel中的验证方法
      context.read<AuthViewModel>().validateToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 启动页永远只显示一个加载动画
    return const Scaffold(
      backgroundColor: Color(0xFF1A182E),
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
