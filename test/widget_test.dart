import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dishaajyoti/main.dart';
import 'package:dishaajyoti/screens/onboarding_screen.dart';
import 'package:dishaajyoti/models/onboarding_model.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DishaAjyotiApp());

    // Verify that splash screen is displayed
    expect(find.text('DishaAjyoti'), findsOneWidget);
  });

  testWidgets('OnboardingScreen displays first slide',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    // Verify first slide content is displayed
    final slides = OnboardingModel.getSlides();
    expect(find.text(slides[0].title), findsOneWidget);
    expect(find.text(slides[0].subtitle), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('OnboardingScreen navigation works', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    final slides = OnboardingModel.getSlides();

    // Verify first slide
    expect(find.text(slides[0].title), findsOneWidget);

    // Tap Next button
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify second slide
    expect(find.text(slides[1].title), findsOneWidget);

    // Verify back button appears
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('OnboardingScreen shows Get Started on last slide',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    final slides = OnboardingModel.getSlides();

    // Navigate to last slide
    for (int i = 0; i < slides.length - 1; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    // Verify last slide content
    expect(find.text(slides.last.title), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
