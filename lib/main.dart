// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'viewmodels/profile_viewmodel.dart';
// 导入新的 ViewModel
import 'viewmodels/home_flow_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        // --- 关键修改 ---
        // 将 HomeFlowViewModel 添加到 Provider 树中
        ChangeNotifierProvider(create: (_) => HomeFlowViewModel()),
      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        title: 'Pet App',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xff1c1b22),
        ),
      ),
    );
  }
}
