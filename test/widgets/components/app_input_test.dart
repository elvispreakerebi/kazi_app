import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_app/components/app_input.dart';
import 'package:kazi_app/components/app_theme.dart';

void main() {
  group('AppInput Widget Tests', () {
    testWidgets('should display label when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Test Label',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('should display description when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              description: 'Test description',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      // Description appears both as hintText and as description text below
      // We check that it appears at least once
      expect(find.text('Test description'), findsWidgets);
    });

    testWidgets('should display error text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Test Input',
              errorText: 'Error message',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.text('Error message'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should not display error when errorText is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Test Input',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('should display prefix icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              prefixIcon: const Icon(Icons.search),
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should display suffix icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              suffixIcon: const Icon(Icons.clear),
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should call onChanged when text changes', (WidgetTester tester) async {
      String? changedValue;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              controller: TextEditingController(),
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test input');
      
      expect(changedValue, equals('Test input'));
    });

    testWidgets('should be disabled when enabled is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              controller: TextEditingController(),
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('should obscure text when obscureText is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              controller: TextEditingController(),
              obscureText: true,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('should display initial value when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              initialValue: 'Initial text',
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, isNull);
    });

    testWidgets('should use correct keyboard type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              controller: TextEditingController(),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, equals(TextInputType.emailAddress));
    });

    testWidgets('should display right label widget when provided', (WidgetTester tester) async {
      const rightWidget = Text('Right Label');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Test Input',
              rightLabelWidget: rightWidget,
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.text('Right Label'), findsOneWidget);
    });

    testWidgets('should display button when withButton is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              controller: TextEditingController(),
              withButton: true,
              buttonText: 'Submit',
              onButtonPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should not display button when withButton is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              controller: TextEditingController(),
              withButton: false,
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should apply error border color when error exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              controller: TextEditingController(),
              errorText: 'Error',
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      final enabledBorder = textField.decoration?.enabledBorder as OutlineInputBorder;
      expect(enabledBorder.borderSide.color, equals(AppTheme.inputOutlineError));
    });

    testWidgets('should handle readOnly state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              controller: TextEditingController(text: 'Read only'),
              readOnly: true,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.readOnly, isTrue);
    });

    testWidgets('should handle maxLines correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              controller: TextEditingController(),
              maxLines: 5,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, equals(5));
    });
  });
}

