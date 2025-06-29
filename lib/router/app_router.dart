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
import '../pages/splash_page.dart';
import '../pages/packages_by_category_page.dart';
import '../viewmodels/auth_viewmodel.dart';

GoRouter createAppRouter(BuildContext context) {
  final authViewModel = context.read<AuthViewModel>();

  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: '/splash',
    refreshListenable: authViewModel,
    // --- 核心修改：使用更健壮的重定向逻辑 ---
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = authViewModel.authStatus;
      final location = state.uri.toString();

      // 规则1：如果App还在初始化，必须停留在/splash页面
      if (authStatus == AuthStatus.initializing) {
        // 如果当前已经是/splash，则返回null避免循环；否则强制跳转到/splash
        return location == '/splash' ? null : '/splash';
      }

      final isLoggedIn = authStatus == AuthStatus.authenticated;

      // 从这里开始，我们知道App已不再初始化。

      // 规则2：如果用户未登录 (unauthenticated)
      if (!isLoggedIn) {
        // 那么，无论他们想去哪里，只要不是登录页本身，都强制送到登录页。
        // 这条规则会正确处理从 /splash 或 /profile 跳转过来的情况。
        return location == '/login' ? null : '/login';
      }

      // 规则3：如果用户已登录 (authenticated)
      // 但他们正位于启动页或登录页（通常是刚登录成功后），则强制送他们到主页。
      if (location == '/splash' || location == '/login') {
        return '/intro';
      }

      // 规则4：如果用户已登录，并且访问的是App内部的其他常规页面，则不进行任何重定向。
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
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
            path: '/creation-store',
            builder: (context, state) => const CreationStorePage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
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
      GoRoute(
        path: '/packages-by-category',
        builder: (context, state) {
          // 确保extra是一个字符串
          if (state.extra is String) {
            final categoryName = state.extra as String;
            return PackagesByCategoryPage(categoryName: categoryName);
          }
          return const Scaffold(body: Center(child: Text("页面参数错误")));
        },
      ),
    ],
  );
}
