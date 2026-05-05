import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Splash Screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the Splash Screen is showing (at least the background or loader)
    expect(find.byType(CircularProgressIndicator).evaluate().isNotEmpty || find.byType(Scaffold).evaluate().isNotEmpty, true);
  });
}
