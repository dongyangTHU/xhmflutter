import 'package:flutter/material.dart';
import 'dart:ui'; // 引入dart:ui库以使用ImageFilter

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet App',
      theme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue),
      home: const MainContainer(),
    );
  }
}

// 步骤1: 将 MainContainer 转换为 StatefulWidget 来管理页面状态
class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++             这是更新后的 _MainContainerState             ++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++      这是根据最新逻辑更新的、最终的 _MainContainerState 类        ++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

class _MainContainerState extends State<MainContainer> {
  late final PageController _pageController;
  int _currentIndex = 0; // 当前选中的导航栏索引 (0:首页, 1:创作, 2:我的)
  // KEY CHANGE: 已移除 "lastContentIndex" 变量，不再需要记忆状态

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // KEY CHANGE: 完全重写了底部菜单栏的点击逻辑
  void _onItemTapped(int index) {
    // 当点击中间的“创作”按钮时，不执行任何操作
    if (index == 1) {
      return;
    }

    // 当点击“首页”时
    if (index == 0) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    // 当点击“我的”时
    else if (index == 2) {
      // 如果当前不在内容页（即在首页），则先滑动到内容页区域
      if (_pageController.page?.round() == 0) {
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }

    // 更新底部栏的选中状态
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        // KEY CHANGE: 动态控制滑动物理效果
        // 当在“我的”页面时(currentIndex == 2)，禁止滑动
        // 其他页面则允许滑动
        physics: _currentIndex == 2
            ? const NeverScrollableScrollPhysics()
            : const ClampingScrollPhysics(),

        // KEY CHANGE: 重写了页面滑动时的逻辑
        onPageChanged: (pageIndex) {
          setState(() {
            // 如果滑动到了内容页（索引为1），则强制将底部导航设置为“创作”
            if (pageIndex == 1) {
              _currentIndex = 1;
            }
            // 如果滑动到了首页（索引为0），则将底部导航设置为“首页”
            else {
              // pageIndex is 0
              _currentIndex = 0;
            }
          });
        },
        children: [
          const IntroPage(), // PageView 的第 0 页
          IndexedStack(
            // IndexedStack 的索引逻辑不变
            index: _currentIndex > 0 ? _currentIndex - 1 : 0,
            children: const [
              HomePage(), // 对应 _currentIndex = 1
              ProfilePage(), // 对应 _currentIndex = 2
            ],
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: BottomNavigationBar(
            backgroundColor: Colors.black.withOpacity(0.3),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            currentIndex: _currentIndex,
            onTap: _onItemTapped, // 绑定全新的点击事件
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                label: '创作',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
            ],
          ),
        ),
      ),
    );
  }
}

// 步骤3: 移除 IntroPage 的 Scaffold
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
    // 不再有 Scaffold，直接返回内容
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
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMenuButton(Icons.add_circle, '开始创作'),
                    _buildMenuButton(Icons.pets, '我的宠物'),
                    _buildMenuButton(Icons.photo_library, '每日写真'),
                    _buildMenuButton(Icons.back_hand, '偷只小猫'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Column(
                children: const [
                  // Text(
                  //   '向上滑动，探索更多',
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 16,
                  //     shadows: [Shadow(blurRadius: 8.0, color: Colors.black54)],
                  //   ),
                  // ),
                  SizedBox(height: 8),
                  Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 30),
                ],
              ),
              const SizedBox(height: 80), // 增加底部空间，防止被导航栏遮挡
            ],
          ),
        ),
      ],
    );
  }
}

// 步骤4: 移除 HomePage 的 Scaffold 和 BottomNavigationBar
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _bannerImagePaths = [
    'assets/images/cat1.jpg',
    'assets/images/cat2.jpg',
    'assets/images/cat3.jpg',
    'assets/images/cat4.jpg',
  ];
  final List<String> _gridImagePaths = [
    'assets/images/cat5.jpg',
    'assets/images/cat6.jpg',
    'assets/images/cat7.jpg',
    'assets/images/cat8.jpg',
  ];
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 不再有 Scaffold，直接返回内容
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/cat9.jpg', fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(color: Colors.black.withOpacity(0.2)),
        ),
        SafeArea(
          // 将 bottom 设置为 false，允许内容滚动到全局导航栏后面
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white.withOpacity(0.7),
                    size: 24,
                  ),
                ),
                _buildTopBar(),
                const SizedBox(height: 20),
                _buildMenuButtons(),
                const SizedBox(height: 20),
                _buildBanner(),
                const SizedBox(height: 24),
                const Text(
                  '相册',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '拍摄完的AI作品显示在此',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                _buildImageGrid(),
                const SizedBox(height: 30),
                _buildCreateButton(),
                // 为底部留出足够空间，防止被全局导航栏遮挡
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- HomePage 的私有构建方法 (无变化) ---
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
          Container(
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
        ],
      ),
    );
  }

  Widget _buildMenuButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMenuButton(Icons.add_circle, '开始创作'),
          _buildMenuButton(Icons.pets, '我的宠物'),
          _buildMenuButton(Icons.photo_library, '每日写真'),
          _buildMenuButton(Icons.back_hand, '偷只小猫'),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _bannerImagePaths.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(_bannerImagePaths[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 10.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bannerImagePaths.length,
                (index) => _buildDotIndicator(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        itemCount: _gridImagePaths.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(_gridImagePaths[index], fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.camera_alt, color: Colors.white),
      label: const Text(
        '点击制作',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7A5CFA),
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: _currentPage == index ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.white54,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++              这是新增的 “个人中心” 页面代码             ++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    // 页面根组件使用 Stack，以实现背景图、模糊层和内容层的叠加
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. 全局背景图
        Image.asset('assets/images/cat9.jpg', fit: BoxFit.cover),
        // 2. 毛玻璃模糊效果层
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
        // 3. 安全区域内的可滚动内容
        SafeArea(
          bottom: false, // 允许内容延伸至底部导航栏之后
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 20),
                _buildMembershipCard(),
                const SizedBox(height: 30),
                _buildPetSection(),
                const SizedBox(height: 20),
                _buildOptionList(),
                const SizedBox(height: 30),
                _buildLogoutButton(),
                // 为底部留出足够空间，防止被全局导航栏遮挡
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 构建页面顶部的头图和用户信息
  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 背景三只猫的图片
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/cat1.jpg',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ).withOpacity(0.5),
            const SizedBox(width: 130), // 为头像留出空间
            Image.asset(
              'assets/images/cat4.jpg',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ).withOpacity(0.5),
          ],
        ),
        // 用户头像和昵称
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/256.png'),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '尊敬的用户SW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 构建“冻干数量”信息卡
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

  // 构建“我的宠物”区块
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
          // 宠物列表
          _buildPetListItem(),
          _buildPetListItem(),
          _buildPetListItem(),
        ],
      ),
    );
  }

  // 构建宠物列表的单个条目
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

  // 构建设置选项列表
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

  // 构建设置列表的单个条目
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

  // 构建底部的“退出”按钮
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

// Opacity extension for convenience
extension OpacityExtension on Widget {
  Widget withOpacity(double opacity) {
    return Opacity(opacity: opacity, child: this);
  }
}
