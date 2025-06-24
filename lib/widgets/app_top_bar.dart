// lib/widgets/app_top_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart'; // 1. 导入 UserViewModel

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧用户信息 (可以保持静态或后续也改为动态)
          Row(
            children: const [
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/256.png'),
                radius: 20,
              ),
              SizedBox(width: 8),
              Text(
                '点击会有惊喜',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          // --- 核心修改: 监听 UserViewModel 来动态显示余额 ---
          Consumer<UserViewModel>(
            builder: (context, userViewModel, child) {
              // 如果正在加载或用户信息为空，显示占位符
              final balance = userViewModel.userInfo?.balance ?? '...';

              return InkWell(
                onTap: () {
                  context.push('/membership-recharge');
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.ac_unit, color: Colors.yellow, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        balance, // 2. 使用动态余额
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '充值',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
