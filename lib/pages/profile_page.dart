import 'dart:io'; // 用于处理文件对象
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 引入图片选择器插件
import 'dart:ui';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // KEY CHANGE: 新增状态变量，用于保存用户选择的壁纸文件
  File? _wallpaperImage;

  // KEY CHANGE: 新增方法，用于从相册选择图片
  Future<void> _pickWallpaper() async {
    final picker = ImagePicker();
    // 从相册选择一张图片
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // 如果用户成功选择了图片，则更新状态
      setState(() {
        _wallpaperImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 页面整体使用深色背景，衬托上方壁纸和下方卡片
    return Container(
      color: const Color(0xff1c1b22),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        // 使用 Column 重新组织页面结构
        child: Column(
          children: [
            // 1. 可点击的壁纸区域 (替换了旧的 _buildHeader)
            _buildWallpaperArea(),

            // 2. “冻干数量”卡片及以下内容保持不变
            const SizedBox(height: 20),
            _buildMembershipCard(),
            const SizedBox(height: 30),
            _buildPetSection(),
            const SizedBox(height: 20),
            _buildOptionList(),
            const SizedBox(height: 30),
            _buildLogoutButton(),
            // 底部留出足够空间
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // KEY CHANGE: 构建可点击的、包含壁纸和用户信息的头部区域
  Widget _buildWallpaperArea() {
    return GestureDetector(
      onTap: _pickWallpaper, // 点击时触发图片选择
      child: SizedBox(
        height: 280, // 定义壁纸区域的固定高度
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 第一层：壁纸图片
            ClipRRect(
              // 使用 ClipRRect 可以方便地在未来添加圆角
              child: _wallpaperImage == null
                  // 如果用户还未选择图片，显示默认壁纸
                  ? Image.asset('assets/images/cat9.jpg', fit: BoxFit.cover)
                  // 否则，显示用户选择的图片
                  : Image.file(_wallpaperImage!, fit: BoxFit.cover),
            ),
            // 第二层：模糊和渐变效果，确保文字清晰可读
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
            // 第三层：实际的用户信息内容
            _buildHeaderContent(),
          ],
        ),
      ),
    );
  }

  // KEY CHANGE: 构建仅包含用户信息的部分，用于叠加在壁纸上
  Widget _buildHeaderContent() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 45,
                backgroundImage: AssetImage('assets/images/256.png'),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              '尊敬的用户SW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 8.0, color: Colors.black54)],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '点击上方区域更换壁纸',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- “冻干数量”卡片及以下的所有 _build* 方法保持完全不变 ---

  Widget _buildMembershipCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3F7E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('冻干数量', style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 4),
              Text(
                '会员剩余时长: 30天',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                '01274992',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '充值',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPetSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '我的宠物档案AI作品',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '管理宠物 >',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPetListItem(),
          _buildPetListItem(),
          _buildPetListItem(),
        ],
      ),
    );
  }

  Widget _buildPetListItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 24, backgroundColor: Colors.white24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('黑八宝宝', style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 4),
              Text(
                'Ta的AI照片集',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildOptionRow('邀请码'),
            _buildOptionRow('联系客服'),
            _buildOptionRow('APP主题'),
            _buildOptionRow('关于我们'),
            _buildOptionRow('意见反馈'),
            _buildOptionRow('账户与安全', showDivider: false),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(String title, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Divider(color: Colors.white.withOpacity(0.1), height: 1),
          ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.15),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {},
        child: const Text(
          '退出',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Opacity extension, if used, can be kept or removed. It's not used in this new version.
