import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../widgets/app_top_bar.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  Widget _buildMenuButton(BuildContext context, IconData icon, String label, String? route) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          context.push(route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, // 缩小按钮尺寸
            height: 56,
            decoration: BoxDecoration(
              boxShadow: [ // 添加投影效果
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svgs/menu_button_bg.svg',
                  width: 56, // 缩小 SVG 尺寸
                  height: 56,
                ),
                Icon(icon, color: Colors.white, size: 24), // 稍微缩小图标
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11, // 稍微缩小文字
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
                Colors.black.withOpacity(0.3), // 稍微调整透明度
                Colors.transparent,
              ],
              stops: const [0.0, 0.25], // 调整渐变范围到顶部 25%
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
              Positioned(
                bottom: 80,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMenuButton(context, Icons.add_circle_outline, '开始创作', '/creation-store'),
                    _buildMenuButton(context, Icons.pets, '我的宠物', null),
                    _buildMenuButton(context, Icons.photo_library_outlined, '每日写真', null),
                    _buildMenuButton(context, Icons.back_hand_outlined, '偷只小猫', null),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 0,
                height: 40,
                child: ClipPath(
                  clipper: _PagePeekClipper(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
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

class _PagePeekClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
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
    return false;
  }
}