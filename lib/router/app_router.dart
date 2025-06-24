// lib/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../pages/creation_store_page.dart';
import '../pages/home_flow_page.dart';
import '../pages/membership_recharge_page.dart';
import '../pages/profile_page.dart';
import '../widgets/main_scaffold.dart';
import '../pages/photo_view_page.dart';
import '../pages/package_detail_page.dart';
import '../pages/login_page.dart';
import '../viewmodels/auth_viewmodel.dart';

// 启动页
class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A182E),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// 定义全局 GoRouter
GoRouter createAppRouter(BuildContext context) {
  final authViewModel = context.read<AuthViewModel>();

  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: '/splash',
    refreshListenable: authViewModel,
    // --- 核心修改: 采用更严谨的重定向逻辑 ---
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = authViewModel.authStatus;
      final isLoggedIn = authStatus == AuthStatus.authenticated;

      // 1. 当认证状态未知时，始终显示启动页
      if (authStatus == AuthStatus.initializing) {
        return '/splash';
      }

      // 2. 定义公共页面 (这里现在只有一个登录页)
      const loginRoute = '/login';
      final isGoingToLogin = state.uri.toString() == loginRoute;

      // 场景 A: 用户已登录
      if (isLoggedIn) {
        // 如果用户已登录，但当前在登录页或启动页，则重定向到主页
        if (isGoingToLogin || state.uri.toString() == '/splash') {
          return '/intro';
        }
      }
      // 场景 B: 用户未登录
      else {
        // 如果用户未登录，并且他们当前访问的不是登录页，则强制他们去登录
        if (!isGoingToLogin) {
          return loginRoute;
        }
      }

      // 3. 在所有其他情况下 (例如，未登录用户访问登录页)，不进行重定向
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      // --- 核心修改: 路由简化 ---
      // 现在只有一个 /login 路由，直接指向手机验证码登录页
      GoRoute(
        path: '/login',
        builder: (context, state) => const PhoneLoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/intro',
            builder: (context, state) => const HomeFlowPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
          path: '/creation-store',
          builder: (context, state) => const CreationStorePage()),
      GoRoute(
          path: '/membership-recharge',
          builder: (context, state) => const MembershipRechargePage()),
      GoRoute(
        path: '/photo-view',
        builder: (context, state) {
          final imagePath = state.extra as String;
          return PhotoViewPage(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: '/package-detail',
        builder: (context, state) => const PackageDetailPage(),
      ),
    ],
  );
}
