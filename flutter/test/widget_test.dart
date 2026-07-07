import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:da_point/screens/splash_screen.dart';

void main() {
  testWidgets('Splash screen shows the DaPoint brand', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.text('DaPoint'), findsOneWidget);
  });
}
