/// Forward AI — Basic Widget Smoke Test
/// Verifies that the app launches without errors.

import 'package:flutter_test/flutter_test.dart';
import 'package:egypt_hackathon/main.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    // Build the ForwardAIApp and trigger a frame.
    await tester.pumpWidget(const ForwardAIApp());

    // Verify the app title is rendered on screen.
    expect(find.text('Forward AI'), findsOneWidget);
  });
}
