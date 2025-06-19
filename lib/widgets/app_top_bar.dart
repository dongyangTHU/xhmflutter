// lib/widgets/app_top_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// 不再需要 'package:intl/intl.dart'

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧部分恢复为简单的 Row 结构
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
          // 右侧部分保持不变
          InkWell(
            onTap: () {
              context.push('/membership-recharge');
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.shield, color: Colors.yellow, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '1502937',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '充值',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
