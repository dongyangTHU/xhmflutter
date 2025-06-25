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
import '../viewmodels/auth_viewmodel.dart';

GoRouter createAppRouter(BuildContext context) {
  final authViewModel = context.read<AuthViewModel>();

  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: '/splash',
    refreshListenable: authViewModel,
    // redirect逻辑成为唯一的导航决策者
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = authViewModel.authStatus;
      final location = state.uri.toString();

      // 1. 如果还在初始化中，且当前不在启动页，则强制导航到启动页
      if (authStatus == AuthStatus.initializing) {
        return location == '/splash' ? null : '/splash';
      }

      final isLoggedIn = authStatus == AuthStatus.authenticated;

      // 2. 如果用户已登录
      if (isLoggedIn) {
        // 如果用户已登录，但当前页面是启动页或登录页，则强制导航到主页
        if (location == '/splash' || location == '/login') {
          return '/intro';
        }
      }
      // 3. 如果用户未登录
      else {
        // 如果用户未登录，但当前不在登录页，则强制导航到登录页
        if (location != '/login') {
          return '/login';
        }
      }

      // 4. 其他所有情况（如已登录访问主页，未登录访问登录页），不进行任何操作
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
