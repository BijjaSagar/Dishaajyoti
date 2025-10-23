import 'package:flutter_test/flutter_test.dart';

import 'package:dishaajyoti/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DishaAjyotiApp());

    // Verify that the app title is displayed.
    expect(find.text('DishaAjyoti - Career & Life Guidance'), findsOneWidget);
  });
}
