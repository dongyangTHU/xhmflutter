// lib/widgets/app_top_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import 'dart:math' as math;

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 根据外部边框SVG的视口尺寸 (268x73) 计算宽高比
    const double svgAspectRatio = 268 / 73;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧用户信息 (保持不变)
          Row(
            children: const [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
              ),
              SizedBox(width: 8),
              Text(
                '点击会有惊喜',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),

          // --- 右侧余额和充值按钮：边框宽度刚好包裹内容，右端和按钮100%契合，数字最多8位 ---
          Consumer<UserViewModel>(
            builder: (context, userViewModel, child) {
              final balance = userViewModel.userInfo?.balance ?? '...';
              String displayBalance;
              if (balance.length > 8) {
                displayBalance = balance.substring(0, 8) + '...';
              } else {
                displayBalance = balance;
              }
              final textPainter = TextPainter(
                text: TextSpan(
                  text: displayBalance,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                textDirection: TextDirection.ltr,
              );
              textPainter.layout();
              final balanceTextWidth = textPainter.width;

              const double iconWidth = 24;
              const double iconPadding = 8;
              const double buttonWidth = 64;
              const double borderLeftPadding = 20; // 可调
              const double borderHeight = 44;
              final double borderWidth = borderLeftPadding + iconWidth + iconPadding + balanceTextWidth + iconPadding + buttonWidth;

              return SizedBox(
                height: borderHeight,
                width: borderWidth,
                child: Stack(
                  children: [
                    // 用自定义画板绘制边框
                    CustomPaint(
                      size: Size(borderWidth, borderHeight),
                      painter: _BorderPainter(),
                    ),
                    // 内容居中对齐
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: borderLeftPadding),
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset('assets/images/ic_currency_diamond.png', width: iconWidth, height: iconWidth, color: Colors.white),
                        ),
                        SizedBox(width: iconPadding),
                        SizedBox(
                          width: balanceTextWidth,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              displayBalance,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        SizedBox(width: iconPadding),
                        // 充值按钮和右端边框完全重合，且高度与边框一致
                        SizedBox(
                          width: buttonWidth,
                          height: borderHeight,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/svgs/recharge_button.svg',
                                height: borderHeight, // 让按钮SVG高度与边框一致
                                fit: BoxFit.fill,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () => context.push('/membership-recharge'),
                                  child: const Text(
                                    '充值',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    paint.color = Colors.white;

    // 参考SVG的path，动态生成左、右端圆角矩形
    final double w = size.width;
    final double h = size.height;
    final double r = math.min(h / 2, 36); // 圆角半径
    final rect = Rect.fromLTWH(1, 1, w - 2, h - 2);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}