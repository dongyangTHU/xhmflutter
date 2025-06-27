// lib/widgets/app_top_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';

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

          // --- 右侧余额和充值按钮：像素级微调 ---
          Consumer<UserViewModel>(
            builder: (context, userViewModel, child) {
              final balance = userViewModel.userInfo?.balance ?? '...';
              const double buttonHeight = 44;
              final double buttonWidth = buttonHeight * svgAspectRatio;

              return SizedBox(
                height: buttonHeight,
                width: buttonWidth,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. 渲染最外层的白色边框 (无填充)
                    SvgPicture.asset(
                      'assets/svgs/recharge_button_border.svg',
                      height: buttonHeight,
                      width: buttonWidth,
                    ),

                    // 2. 使用Stack来精确定位内部元素
                    Stack(
                      children: [
                        // 左对齐的内容: 图标 + 余额
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 24.04,
                                  height: 24.01,
                                  child: Image.asset(
                                    'assets/images/ic_currency_diamond.png',
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  balance,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 右对齐的内容: 使用Positioned和Transform进行像素级微调
                        Positioned(
                          top: 0,
                          bottom: 0,
                          // 通过设置负值right，强制消除SVG内部右侧的透明边距
                          right: -5.0,
                          child: GestureDetector(
                            onTap: () {
                              context.push('/membership-recharge');
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/svgs/recharge_button.svg',
                                ),
                                // 使用Transform.translate微调文字位置，实现完美居中
                                Transform.translate(
                                  offset: const Offset(0, -1.5), // 垂直方向向上微调1.5像素
                                  child: const Text(
                                    '充值',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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