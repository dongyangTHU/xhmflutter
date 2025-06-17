import 'package:flutter/material.dart';
import 'dart:ui'; // 引入dart:ui库以使用ImageFilter

// 引入分离出去的页面文件
import 'pages/home_page.dart';
import 'pages/intro_page.dart';
import 'pages/profile_page.dart';

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
    if (tappedIndex == 1) {
      return;
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
            // 这个 physics 是正确的，允许页面正常滚动
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
