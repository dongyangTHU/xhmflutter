// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/home_flow_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart'; // 1. 导入 AuthViewModel

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. 将 AuthViewModel 放在 UserViewModel 上方，以便 UserViewModel 可以访问它
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => HomeFlowViewModel()),
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
