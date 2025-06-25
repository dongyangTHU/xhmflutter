// lib/pages/login_page.dart

import 'package:flutter/foundation.dart'; // 引入 kDebugMode
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../viewmodels/auth_viewmodel.dart';

// 不再需要导入UserViewModel
// import '../viewmodels/user_viewmodel.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({Key? key}) : super(key: key);

  @override
  _PhoneLoginPageState createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  final ValueNotifier<int> _countdownNotifier = ValueNotifier<int>(0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().clearError();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _countdownNotifier.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdownNotifier.value > 0) {
        _countdownNotifier.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _countdownNotifier.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A182E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.pets, color: Colors.white, size: 32),
            SizedBox(width: 8),
            Text('小红猫', style: TextStyle(color: Colors.white, fontSize: 22)),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text('验证码登录',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '请输入手机号',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '请输入验证码',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return ValueListenableBuilder<int>(
                      valueListenable: _countdownNotifier,
                      builder: (context, countdownValue, _) {
                        final isCountingDown = countdownValue > 0;
                        return SizedBox(
                          width: 110,
                          child: ElevatedButton(
                            onPressed: isCountingDown || authViewModel.isLoading
                                ? null
                                : () async {
                                    if (_phoneController.text.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text("请输入手机号")));
                                      return;
                                    }
                                    final success = await context
                                        .read<AuthViewModel>()
                                        .sendSmsCode(_phoneController.text);
                                    if (mounted && success) {
                                      _startTimer();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text("验证码已发送")));
                                    } else if (mounted && !success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(context
                                                      .read<AuthViewModel>()
                                                      .error ??
                                                  "发送失败，请稍后重试")));
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor:
                                  Colors.grey.withOpacity(0.3),
                              backgroundColor: const Color(0xFF7A5CFA),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: authViewModel.isLoading && !isCountingDown
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : Text(
                                    isCountingDown
                                        ? '$countdownValue s'
                                        : '发送验证码',
                                    style:
                                        const TextStyle(color: Colors.white)),
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
            const SizedBox(height: 32),
            Consumer<AuthViewModel>(
              builder: (context, authViewModel, child) {
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authViewModel.isLoading
                            ? null
                            : () {
                                if (_phoneController.text.isEmpty ||
                                    _codeController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("手机号或验证码不能为空")));
                                  return;
                                }
                                // --- 核心修改: 调用新的loginWithSms，不再需要传入UserViewModel ---
                                context.read<AuthViewModel>().loginWithSms(
                                      _phoneController.text,
                                      _codeController.text,
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A5CFA),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                        child: authViewModel.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 3))
                            : const Text('登录',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authViewModel.isLoading
                              ? null
                              : () {
                                  // --- 核心修改: 调用新的loginForTest，不再需要传入UserViewModel ---
                                  context.read<AuthViewModel>().loginForTest();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade700,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Text('测试跳转 (Debug Only)',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                    if (authViewModel.error != null &&
                        !authViewModel.isLoading) ...[
                      const SizedBox(height: 20),
                      Text(authViewModel.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent)),
                    ]
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const PhoneLoginPage();
  }
}
