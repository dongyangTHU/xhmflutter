// lib/pages/packages_by_category_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PackagesByCategoryPage extends StatelessWidget {
  // 构造函数只接收一个名为 categoryName 的字符串
  final String categoryName;

  const PackagesByCategoryPage({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A182E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A182E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        // 使用传入的分类名作为标题
        title: Text(
          categoryName,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      // 使用 GridView 来构建网格布局
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6, // 写死6个项目用于UI展示
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          return _buildStaticPhotoCard(context);
        },
      ),
    );
  }

  Widget _buildStaticPhotoCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/package-detail');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/cat1.jpg', // 使用本地占位图
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('套系名称',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('8.8万用户使用',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Row(
                children: const [
                  Icon(Icons.ac_unit, color: Colors.yellow, size: 16),
                  SizedBox(width: 4),
                  Text('299',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
