// lib/pages/photo_view_page.dart

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewPage extends StatelessWidget {
  final String imagePath;

  const PhotoViewPage({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 使用一个半透明的 AppBar，使其不那么突兀
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        // 自定义返回按钮，使其更醒目
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // PhotoView 组件负责显示和交互
      body: PhotoView(
        // 加载传入的图片资源
        imageProvider: AssetImage(imagePath),
        // 设置初始和最小缩放比例
        initialScale: PhotoViewComputedScale.contained,
        minScale: PhotoViewComputedScale.contained,
        // 设置最大缩放比例
        maxScale: PhotoViewComputedScale.covered * 2.0,
        // 加载时的占位组件
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        ),
        // 设置背景装饰
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        // 英雄动画标签，实现平滑的过渡效果
        heroAttributes: PhotoViewHeroAttributes(tag: imagePath),
      ),
    );
  }
}
