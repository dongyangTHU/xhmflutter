// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/home_flow_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- 核心修改: 使用 ChangeNotifierProxyProvider 来正确处理ViewModel之间的依赖 ---
    return MultiProvider(
      providers: [
        // 1. 首先独立创建不需要依赖其他ViewModel的Provider
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => HomeFlowViewModel()),

        // 2. 使用 ChangeNotifierProxyProvider 创建 AuthViewModel
        // 它会在创建 AuthViewModel 的同时，将已经存在的 UserViewModel 实例“注入”进去
        ChangeNotifierProxyProvider<UserViewModel, AuthViewModel>(
          // `create` 方法用于创建 AuthViewModel 的初始实例
          create: (context) => AuthViewModel(context.read<UserViewModel>()),
          // `update` 方法在 UserViewModel 更新时，可以更新 AuthViewModel（如果需要）
          update: (context, userViewModel, previousAuthViewModel) {
            // 在这个场景下，我们只需要创建时注入一次即可，所以可以直接返回旧实例
            return previousAuthViewModel ?? AuthViewModel(userViewModel);
          },
        ),
      ],
      // 3. 使用 Consumer 来确保 router 可以访问 AuthViewModel
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, _) {
          return MaterialApp.router(
            routerConfig: createAppRouter(context), // 4. 创建并传入 router
            debugShowCheckedModeBanner: false,
            title: 'Pet App',
            theme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: const Color(0xff1c1b22),
            ),
          );
        },
      ),
    );
  }
}
