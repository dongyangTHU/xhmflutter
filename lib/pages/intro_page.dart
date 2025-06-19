// lib/pages/intro_page.dart

import 'dart:ui'; // 引入ImageFilter需要这个包
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../widgets/app_top_bar.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  Widget _buildMenuButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDay = DateFormat('d').format(DateTime.now());
    final String formattedMonth =
        DateFormat('MMM').format(DateTime.now()).toUpperCase();

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/cat1.jpg',
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.transparent,
                Colors.black.withOpacity(0.4),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppTopBar(),
              ),
              Positioned(
                top: 80,
                left: 24,
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size.infinite,
                        painter: _DiagonalLinePainter(),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, top: 0),
                          child: Text(
                            formattedDay,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 38,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4, bottom: 0),
                          child: Text(
                            formattedMonth,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- 关键布局修改 ---
              // 1. 将按钮和弧形装饰分离为两个独立的 Positioned 组件

              // 按钮组，位置保持不变
              Positioned(
                bottom: 80,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.push('/creation-store');
                      },
                      child: _buildMenuButton(Icons.add_circle_outline, '开始创作'),
                    ),
                    _buildMenuButton(Icons.pets, '我的宠物'),
                    _buildMenuButton(Icons.photo_library_outlined, '每日写真'),
                    _buildMenuButton(Icons.back_hand_outlined, '偷只小猫'),
                  ],
                ),
              ),

              // 单独的“磨砂玻璃”弧形装饰模块
              Positioned(
                left: 20,
                right: 20,
                bottom: 0,
                height: 40, // 控制磨砂区域的高度和弧度
                child: ClipPath(
                  // 使用我们新的 Clipper 来裁剪
                  clipper: _PagePeekClipper(),
                  child: BackdropFilter(
                    // 应用高斯模糊效果
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      // 在模糊层上叠加一层半透明白色，使其呈现“磨砂”质感
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    const double padding = 12.0;
    final Offset startingPoint = Offset(size.width - padding, padding);
    final Offset endingPoint = Offset(padding, size.height - padding);

    canvas.drawLine(
      startingPoint,
      endingPoint,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// --- 新增 Clipper 类，替换掉 _PagePeekPainter ---
class _PagePeekClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // 这个路径的逻辑与我们之前绘制实心色块的逻辑完全相同
    const double dipHeight = 40.0;
    final path = Path();
    path.moveTo(0, dipHeight);
    path.quadraticBezierTo(
      size.width / 2,
      0,
      size.width,
      dipHeight,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // 因为形状是固定的，所以不需要重新裁剪
    return false;
  }
}
