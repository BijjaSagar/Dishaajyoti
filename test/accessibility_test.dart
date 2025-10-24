import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dishaajyoti/widgets/buttons/primary_button.dart';
import 'package:dishaajyoti/widgets/buttons/secondary_button.dart';
import 'package:dishaajyoti/widgets/inputs/custom_text_field.dart';
import 'package:dishaajyoti/theme/app_colors.dart';
import 'package:dishaajyoti/utils/accessibility_utils.dart';

void main() {
  group('Touch Target Size Tests', () {
    testWidgets('PrimaryButton meets minimum touch target size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      final buttonSize = tester.getSize(find.byType(PrimaryButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0),
          reason:
              'Button height should meet minimum touch target size of 48dp');
    });

    testWidgets('SecondaryButton meets minimum touch target size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      final buttonSize = tester.getSize(find.byType(SecondaryButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0),
          reason:
              'Button height should meet minimum touch target size of 48dp');
    });
  });

  group('Widget Rendering Tests', () {
    testWidgets('PrimaryButton renders with label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('SecondaryButton renders with label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(
              label: 'Secondary Action',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SecondaryButton), findsOneWidget);
      expect(find.text('Secondary Action'), findsOneWidget);
    });

    testWidgets('CustomTextField renders with label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              label: 'Email',
              hint: 'Enter your email',
            ),
          ),
        ),
      );

      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('CustomTextField shows error message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              label: 'Email',
              hint: 'Enter your email',
              errorText: 'Invalid email',
            ),
          ),
        ),
      );

      expect(find.text('Invalid email'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('Loading button shows loading indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Login',
              onPressed: null,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Color Contrast Tests', () {
    test('Black on white meets WCAG AA standards', () {
      final ratio = AccessibilityUtils.calculateContrastRatio(
        AppColors.black,
        AppColors.white,
      );
      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'Black on white should have contrast ratio >= 4.5:1');
    });

    test('Primary blue on white meets WCAG AA standards', () {
      final ratio = AccessibilityUtils.calculateContrastRatio(
        AppColors.primaryBlue,
        AppColors.white,
      );
      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'Primary blue on white should have contrast ratio >= 4.5:1');
    });

    test('White on primary blue meets WCAG AA standards', () {
      final ratio = AccessibilityUtils.calculateContrastRatio(
        AppColors.white,
        AppColors.primaryBlue,
      );
      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'White on primary blue should have contrast ratio >= 4.5:1');
    });

    test('Success color has measurable contrast', () {
      final ratio = AccessibilityUtils.calculateContrastRatio(
        AppColors.success,
        AppColors.white,
      );
      expect(ratio, greaterThanOrEqualTo(2.5),
          reason:
              'Success color should have measurable contrast (suitable for large text)');
    });

    test('Error color meets WCAG AA standards', () {
      final ratio = AccessibilityUtils.calculateContrastRatio(
        AppColors.error,
        AppColors.white,
      );
      expect(ratio, greaterThanOrEqualTo(3.0),
          reason: 'Error color should have sufficient contrast');
    });
  });

  group('AccessibilityUtils Tests', () {
    test('createSemanticLabel combines information correctly', () {
      final label = AccessibilityUtils.createSemanticLabel(
        label: 'Login',
        hint: 'Double tap to login',
        isEnabled: true,
      );

      expect(label, contains('Login'));
      expect(label, contains('Double tap to login'));
    });

    test('createSemanticLabel handles disabled state', () {
      final label = AccessibilityUtils.createSemanticLabel(
        label: 'Submit',
        isEnabled: false,
      );

      expect(label, contains('Submit'));
      expect(label, contains('disabled'));
    });

    test('createSemanticLabel handles selected state', () {
      final label = AccessibilityUtils.createSemanticLabel(
        label: 'Home',
        isSelected: true,
      );

      expect(label, contains('Home'));
      expect(label, contains('selected'));
    });

    test('meetsContrastRatio validates correctly', () {
      // Black on white should pass
      expect(
        AccessibilityUtils.meetsContrastRatio(
          AppColors.black,
          AppColors.white,
        ),
        isTrue,
      );

      // Very light gray on white should fail
      expect(
        AccessibilityUtils.meetsContrastRatio(
          const Color(0xFFEEEEEE),
          AppColors.white,
        ),
        isFalse,
      );
    });
  });

  group('Text Scaling Tests', () {
    testWidgets('Text scales with system settings',
        (WidgetTester tester) async {
      // Test with normal text scale
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Text(
                  'Test Text',
                  style: Theme.of(context).textTheme.bodyLarge,
                );
              },
            ),
          ),
        ),
      );

      final normalSize = tester.getSize(find.text('Test Text'));

      // Test with 2x text scaling
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    'Test Text',
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                },
              ),
            ),
          ),
        ),
      );

      final scaledSize = tester.getSize(find.text('Test Text'));

      // Scaled text should be larger
      expect(scaledSize.height, greaterThan(normalSize.height),
          reason: 'Text should scale with system text size settings');
    });
  });
}
