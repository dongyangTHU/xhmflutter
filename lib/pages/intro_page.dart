// lib/pages/intro_page.dart

import 'package:flutter/material.dart';
import '../widgets/app_top_bar.dart'; // KEY CHANGE: 引入新的通用组件
import 'creation_store_page.dart';
import 'membership_recharge_page.dart';

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
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/cat9.jpg', fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.6),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              // KEY CHANGE: 直接使用 AppTopBar 组件
              const AppTopBar(),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreationStorePage(),
                          ),
                        );
                      },
                      child: _buildMenuButton(Icons.add_circle, '开始创作'),
                    ),
                    _buildMenuButton(Icons.pets, '我的宠物'),
                    _buildMenuButton(Icons.photo_library, '每日写真'),
                    _buildMenuButton(Icons.back_hand, '偷只小猫'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Column(
                children: const [
                  SizedBox(height: 8),
                  Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 30),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }
}
