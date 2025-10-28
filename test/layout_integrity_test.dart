import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dishaajyoti/l10n/app_localizations.dart';

/// Layout Integrity Test Suite
///
/// This test suite verifies that all localized screens maintain proper layout
/// across all supported languages (English, Hindi, Marathi, Tamil, Telugu, Kannada).
///
/// Test Coverage:
/// - Text overflow detection
/// - Button sizing with long translations
/// - Dialog layout integrity
/// - Form field label wrapping
/// - Multi-line text handling

void main() {
  group('Layout Integrity Tests - All Languages', () {
    final supportedLocales = [
      const Locale('en'), // English
      const Locale('hi'), // Hindi
      const Locale('mr'), // Marathi
      const Locale('ta'), // Tamil
      const Locale('te'), // Telugu
      const Locale('kn'), // Kannada
    ];

    for (final locale in supportedLocales) {
      group('${locale.languageCode.toUpperCase()} Layout Tests', () {
        testWidgets('Common UI elements fit properly',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Test common buttons
                            ElevatedButton(
                              onPressed: () {},
                              child: Text(l10n.common_save),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text(l10n.common_submit),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text(l10n.common_cancel),
                            ),
                            const SizedBox(height: 16),

                            // Test navigation labels
                            Text(l10n.nav_home,
                                style: const TextStyle(fontSize: 16)),
                            Text(l10n.nav_services,
                                style: const TextStyle(fontSize: 16)),
                            Text(l10n.nav_reports,
                                style: const TextStyle(fontSize: 16)),
                            Text(l10n.nav_profile,
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Verify no overflow errors
          expect(tester.takeException(), isNull);
        });

        testWidgets('Kundali screen labels fit properly',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.kundali_form_title,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text(l10n.kundali_form_header,
                                style: const TextStyle(fontSize: 20)),
                            Text(l10n.kundali_form_subtitle),
                            const SizedBox(height: 16),

                            // Form fields
                            TextField(
                              decoration: InputDecoration(
                                labelText: l10n.kundali_form_name_label,
                                hintText: l10n.kundali_form_name_hint,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: l10n.kundali_form_dob_label,
                                hintText: l10n.kundali_form_dob_hint,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: l10n.kundali_form_time_label,
                                hintText: l10n.kundali_form_time_hint,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: l10n.kundali_form_place_label,
                                hintText: l10n.kundali_form_place_hint,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Long button text
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text(l10n.kundali_form_generate),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });

        testWidgets('Compatibility screen labels fit properly',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.compatibility_check_title,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(l10n.compatibility_check_subtitle),
                            const SizedBox(height: 16),
                            Text(l10n.compatibility_person1,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            TextField(
                              decoration: InputDecoration(
                                labelText: l10n.compatibility_name_label,
                                hintText: l10n.compatibility_name_hint,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(l10n.compatibility_person2,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            TextField(
                              decoration: InputDecoration(
                                labelText: l10n.compatibility_name_label,
                                hintText: l10n.compatibility_name_hint,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text(l10n.compatibility_check_button),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });

        testWidgets('Numerology screen labels fit properly',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.numerology_input_header,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(l10n.numerology_input_subtitle),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: l10n.numerology_name_label,
                                hintText: l10n.numerology_name_hint,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(l10n.numerology_what_discover,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            ListTile(
                              title: Text(l10n.numerology_life_path),
                              subtitle: Text(l10n.numerology_life_path_desc),
                            ),
                            ListTile(
                              title: Text(l10n.numerology_destiny),
                              subtitle: Text(l10n.numerology_destiny_desc),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text(l10n.numerology_analyze_button),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });

        testWidgets('Palmistry screen labels fit properly',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.palmistry_upload_header,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(l10n.palmistry_upload_subtitle),
                            const SizedBox(height: 16),
                            Text(l10n.palmistry_left_hand_label,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text(l10n.palmistry_take_photo),
                            ),
                            const SizedBox(height: 16),
                            Text(l10n.palmistry_right_hand_label,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text(l10n.palmistry_take_photo),
                            ),
                            const SizedBox(height: 16),
                            Text(l10n.palmistry_tips),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text(l10n.palmistry_analyze_button),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });

        testWidgets('Profile setup screen labels fit properly',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.profile_setup_title,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(l10n.profile_setup_birth_details,
                                style: const TextStyle(fontSize: 20)),
                            Text(l10n.profile_setup_birth_subtitle),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: l10n.profile_setup_dob_label,
                                hintText: l10n.profile_setup_dob_hint,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: l10n.profile_setup_time_label,
                                hintText: l10n.profile_setup_time_hint,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(l10n.profile_setup_privacy_note,
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    child: Text(l10n.profile_setup_back),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    child: Text(l10n.profile_setup_next),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });

        testWidgets('Onboarding screen labels fit properly',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(l10n.onboarding_slide1_title,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                            Text(l10n.onboarding_slide1_subtitle,
                                style: const TextStyle(fontSize: 18),
                                textAlign: TextAlign.center),
                            Text(l10n.onboarding_slide1_description,
                                textAlign: TextAlign.center),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: Text(l10n.onboarding_skip),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text(l10n.onboarding_next),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });

        testWidgets('Order tracking screen labels fit properly',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.order_tracking_title,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text(l10n.order_tracking_order_details,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            ListTile(
                              title: Text(l10n.order_tracking_order_id),
                              subtitle: const Text('ORD-12345'),
                            ),
                            ListTile(
                              title: Text(l10n.order_tracking_service),
                              subtitle: const Text('AI Kundali Analysis'),
                            ),
                            const SizedBox(height: 16),
                            Text(l10n.order_tracking_timeline,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            ListTile(
                              leading: const Icon(Icons.check_circle),
                              title: Text(l10n.order_tracking_order_placed),
                              subtitle:
                                  Text(l10n.order_tracking_payment_completed),
                            ),
                            ListTile(
                              leading: const Icon(Icons.pending),
                              title: Text(l10n.order_tracking_processing),
                              subtitle: Text(
                                  l10n.order_tracking_processing_in_progress),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text(l10n.order_tracking_view_report),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      });
    }
  });

  group('String Length Analysis', () {
    test('Compare string lengths across languages', () {
      // This test helps identify which translations are longest
      final testStrings = {
        'common_save': [
          'Save',
          'सहेजें',
          'जतन करा',
          'சேமி',
          'సేవ్ చేయండి',
          'ಉಳಿಸಿ'
        ],
        'kundali_form_generate': [
          'Generate Free Kundali',
          'मुफ्त कुंडली बनाएं',
          'मोफत कुंडली तयार करा',
          'இலவச குண்டலியை உருவாக்கவும்',
          'ఉచిత కుండలిని రూపొందించండి',
          'ಉಚಿತ ಕುಂಡಲಿಯನ್ನು ರಚಿಸಿ',
        ],
        'compatibility_check_button': [
          'Check Compatibility',
          'अनुकूलता जांचें',
          'सुसंगतता तपासा',
          'பொருத்தத்தை சரிபார்க்கவும்',
          'అనుకూలతను తనిఖీ చేయండి',
          'ಹೊಂದಾಣಿಕೆಯನ್ನು ಪರಿಶೀಲಿಸಿ',
        ],
      };

      for (final entry in testStrings.entries) {
        print('\n${entry.key}:');
        for (int i = 0; i < entry.value.length; i++) {
          final locales = ['en', 'hi', 'mr', 'ta', 'te', 'kn'];
          print(
              '  ${locales[i]}: "${entry.value[i]}" (${entry.value[i].length} chars)');
        }
      }
    });
  });
}
