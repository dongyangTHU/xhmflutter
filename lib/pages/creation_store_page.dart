// lib/pages/creation_store_page.dart

import 'package:flutter/material.dart';

class CreationStorePage extends StatefulWidget {
  const CreationStorePage({super.key});

  @override
  State<CreationStorePage> createState() => _CreationStorePageState();
}

// 使用 TickerProviderStateMixin 来为 TabController 提供 Ticker
class _CreationStorePageState extends State<CreationStorePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 定义主题色
  static const Color _scaffoldBgColor = Color(0xFF1A182E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // 宠物写真 视图
                PetPhotoView(),
                // 人宠合照 视图
                HumanPetPhotoView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _scaffoldBgColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        '写真商店',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorColor: const Color(0xFF7A5CFA),
      indicatorWeight: 3,
      indicatorPadding: const EdgeInsets.symmetric(horizontal: 24),
      tabs: const [
        Tab(text: '宠物写真'),
        Tab(text: '人宠合照'),
      ],
    );
  }
}

// 宠物写真视图
class PetPhotoView extends StatelessWidget {
  const PetPhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset('assets/images/cat2.jpg'), // 示例图片
          ),
          const SizedBox(height: 24),
          _buildSection(context, '热门', '时下最喜爱的套系', isPet: true),
          const SizedBox(height: 24),
          _buildSection(context, '优惠', '超值限时特价套系', isPet: true),
        ],
      ),
    );
  }
}

// 人宠合照视图
class HumanPetPhotoView extends StatelessWidget {
  const HumanPetPhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 创建个人AI形象按钮
          ElevatedButton.icon(
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              '创建个人AI形象',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {},
          ),
          const SizedBox(height: 24),
          _buildSection(context, '热门', '时下最喜爱的套系', isPet: false),
          const SizedBox(height: 24),
          _buildSection(context, '优惠', '超值限时特价套系', isPet: true), // 原型图这里还是宠物
        ],
      ),
    );
  }
}

// --- 通用辅助方法 ---

// 构建内容分区
Widget _buildSection(
  BuildContext context,
  String title,
  String subtitle, {
  required bool isPet,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          Text('更多套系 >', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 220, // 固定高度的横向滚动列表
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3, // 示例数量
          itemBuilder: (context, index) {
            return _buildPhotoCard(isPet: isPet, index: index);
          },
        ),
      ),
    ],
  );
}

// 构建写真套系卡片
Widget _buildPhotoCard({required bool isPet, required int index}) {
  // 示例数据
  final petImages = [
    'assets/images/cat5.jpg',
    'assets/images/cat6.jpg',
    'assets/images/cat7.jpg',
  ];
  final humanPetImages = [
    'assets/images/cat1.jpg',
    'assets/images/cat2.jpg',
    'assets/images/cat3.jpg',
  ];
  final images = isPet ? petImages : humanPetImages;
  final price = isPet ? '299' : '599';

  return Container(
    width: 160,
    margin: const EdgeInsets.only(right: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              images[index],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '套系名称',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '节日盛典 | 8.8万用户使用',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.yellow, size: 16),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
