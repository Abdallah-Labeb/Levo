import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levo/core/widgets/metal_panel.dart';
import 'package:levo/core/widgets/led_display.dart';

void main() {
  group('Core Widgets Smoke Tests', () {
    testWidgets('MetalPanel renders child content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetalPanel(
              child: Text('Machined Edge'),
            ),
          ),
        ),
      );

      expect(find.text('Machined Edge'), findsOneWidget);
    });

    testWidgets('LedDisplay displays value and optional unit', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LedDisplay(
              value: '1.24',
              unit: '°',
            ),
          ),
        ),
      );

      expect(find.text('1.24'), findsOneWidget);
      expect(find.text('°'), findsOneWidget);
    });
  });
}
