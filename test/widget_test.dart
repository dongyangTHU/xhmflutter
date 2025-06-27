// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 注意：请确保这里的 'xhmflutter' 是你项目 pubspec.yaml 中定义的 name
import 'package:test1/main.dart'; 

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // ===================================================================
    // V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V
    
    // 之前，你的代码直接在这里进行检查，导致了失败。
    // expect(find.text('0'), findsOneWidget); // 这是之前导致错误的那一行 (大概在第19行)
    
    // 现在，我们添加一行 pump() 或 pumpAndSettle() 来等待 UI 渲染完成。
    // 对于这个简单的应用，pump() 就足够了。
    await tester.pump(); 

    // ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
    // ===================================================================


    // Verify that our counter starts at 0.
    // 现在再来检查，测试就能成功找到这个 Widget 了。
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}