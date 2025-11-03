import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_app/components/app_checkbox.dart';
import 'package:kazi_app/components/app_theme.dart';

void main() {
  group('AppCheckbox Widget Tests', () {
    testWidgets('should display checkbox when value is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: false,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('should display checked icon when value is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: true,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should call onChanged when tapped', (WidgetTester tester) async {
      bool? changedValue;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: false,
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(changedValue, isTrue);
    });

    testWidgets('should toggle value when tapped', (WidgetTester tester) async {
      bool currentValue = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AppCheckbox(
                  value: currentValue,
                  onChanged: (value) {
                    setState(() {
                      currentValue = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsNothing);
      
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(currentValue, isTrue);
    });

    testWidgets('should display label when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: false,
              onChanged: (value) {},
              label: 'Test Label',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('should not display label when label is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: false,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsNothing);
    });

    testWidgets('should display error text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: false,
              onChanged: (value) {},
              errorText: 'Error message',
            ),
          ),
        ),
      );

      expect(find.text('Error message'), findsOneWidget);
    });

    testWidgets('should not display error when errorText is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: false,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('Error message'), findsNothing);
    });

    testWidgets('should not call onChanged when disabled', (WidgetTester tester) async {
      bool wasChanged = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: false,
              onChanged: (value) {
                wasChanged = true;
              },
              enabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(wasChanged, isFalse);
    });

    testWidgets('should apply error color when error exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: true,
              onChanged: (value) {},
              errorText: 'Error',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppCheckbox),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border?;
      expect(border?.top.color, equals(AppTheme.inputOutlineError));
    });

    testWidgets('should apply disabled color when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: false,
              onChanged: (value) {},
              enabled: false,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppCheckbox),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border?;
      expect(border?.top.color, equals(AppTheme.inputOutline));
    });

    testWidgets('should apply primary color when checked and enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: true,
              onChanged: (value) {},
              enabled: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppCheckbox),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppTheme.primary));
    });

    testWidgets('should apply white background when unchecked', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: false,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppCheckbox),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppTheme.white));
    });

    testWidgets('should have correct checkbox size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: false,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppCheckbox),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.constraints?.maxWidth, equals(22.0));
      expect(container.constraints?.maxHeight, equals(22.0));
    });

    testWidgets('should display label with error color when error exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: false,
              onChanged: (value) {},
              label: 'Error Label',
              errorText: 'Error',
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Error Label'));
      expect(textWidget.style?.color, equals(AppTheme.inputOutlineError));
    });

    testWidgets('should display label with disabled color when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCheckbox(
              value: false,
              onChanged: (value) {},
              label: 'Disabled Label',
              enabled: false,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Disabled Label'));
      expect(textWidget.style?.color, equals(AppTheme.inputOutlineDisabled));
    });
  });
}

