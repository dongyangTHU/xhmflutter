// lib/main.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'pages/home_page.dart';
import 'pages/intro_page.dart';
import 'pages/profile_page.dart';
import 'pages/creation_store_page.dart'; // KEY CHANGE: 引入新页面

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet App',
      theme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue),
      home: const MainContainer(),
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  late final PageController _pageController;
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int tappedIndex) {
    // KEY CHANGE: 点击“创作”(索引1)时，跳转到新页面
    if (tappedIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreationStorePage()),
      );
      return; // 不更新底部导航栏状态，保持当前页的高亮
    }

    if (tappedIndex == 2) {
      if (_bottomNavIndex != 2) {
        setState(() {
          _bottomNavIndex = 2;
        });
      }
      return;
    }

    if (_bottomNavIndex == 2) {
      setState(() {
        _bottomNavIndex = 0;
      });
    }

    int targetPage = tappedIndex;
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool shouldShowProfilePage = _bottomNavIndex == 2;
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: shouldShowProfilePage ? 1 : 0,
        children: [
          PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            onPageChanged: (pageIndex) {
              setState(() {
                _bottomNavIndex = 0;
              });
            },
            children: const [IntroPage(), HomePage()],
          ),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: BottomNavigationBar(
            backgroundColor: Colors.black.withOpacity(0.3),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            currentIndex: _bottomNavIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                label: '创作',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
            ],
          ),
        ),
      ),
    );
  }
}
