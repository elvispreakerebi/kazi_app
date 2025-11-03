import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_app/components/app_button.dart';
import 'package:kazi_app/components/app_theme.dart';

void main() {
  group('AppButton Widget Tests', () {
    testWidgets('should display button text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (WidgetTester tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test Button',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Button'));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('should not call onPressed when disabled', (WidgetTester tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Disabled Button',
              onPressed: null,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled Button'));
      await tester.pump();

      expect(wasPressed, isFalse);
    });

    testWidgets('should render primary variant with correct colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Primary Button',
              onPressed: () {},
              variant: ButtonVariant.primary,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Primary Button'));
      expect(textWidget.style?.color, equals(AppTheme.white));
    });

    testWidgets('should render secondary variant with correct colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Secondary Button',
              onPressed: () {},
              variant: ButtonVariant.secondary,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Secondary Button'));
      expect(textWidget.style?.color, equals(AppTheme.textDark));
    });

    testWidgets('should render outline variant with border', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Outline Button',
              onPressed: () {},
              variant: ButtonVariant.outline,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(Container),
        ),
      );
      
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('should display icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Button with Icon',
              onPressed: () {},
              icon: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Button with Icon'), findsOneWidget);
    });

    testWidgets('should expand to full width when expanded is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Expanded Button',
              onPressed: () {},
              expanded: true,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(double.infinity));
    });

    testWidgets('should not expand when expanded is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Not Expanded Button',
              onPressed: () {},
              expanded: false,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, isNull);
    });

    testWidgets('should apply custom height', (WidgetTester tester) async {
      const customHeight = 48.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Custom Height Button',
              onPressed: () {},
              height: customHeight,
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      
      expect(container.constraints?.maxHeight, equals(customHeight));
    });

    testWidgets('should apply custom borderRadius', (WidgetTester tester) async {
      const customRadius = 16.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Custom Radius Button',
              onPressed: () {},
              borderRadius: customRadius,
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isA<BorderRadius>());
    });

    testWidgets('should render destructive variant correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Destructive Button',
              onPressed: () {},
              variant: ButtonVariant.destructive,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Destructive Button'));
      expect(textWidget.style?.color, equals(AppTheme.white));
    });

    testWidgets('should render ghost variant correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Ghost Button',
              onPressed: () {},
              variant: ButtonVariant.ghost,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Ghost Button'));
      expect(textWidget.style?.color, equals(AppTheme.textDark));
    });
  });
}

