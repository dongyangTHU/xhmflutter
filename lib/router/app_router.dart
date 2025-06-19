// lib/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/creation_store_page.dart';
import '../pages/home_flow_page.dart';
import '../pages/membership_recharge_page.dart';
import '../pages/profile_page.dart';
import '../widgets/main_scaffold.dart';
// --- 导入新页面 ---
import '../pages/photo_view_page.dart';
import '../pages/package_detail_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeFlowPage(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfilePage()),
        ),
      ],
    ),

    // 其他顶层路由
    GoRoute(
      path: '/creation-store',
      builder: (context, state) => const CreationStorePage(),
    ),
    GoRoute(
      path: '/membership-recharge',
      builder: (context, state) => const MembershipRechargePage(),
    ),

    // --- 新增路由规则 ---
    GoRoute(
      path: '/photo-view',
      builder: (context, state) {
        // 从 extra 参数中安全地获取图片路径
        final String imagePath = state.extra as String;
        return PhotoViewPage(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/package-detail',
      builder: (context, state) {
        // 后续可以从 state.extra 中接收套系数据
        return const PackageDetailPage();
      },
    ),
  ],
);
