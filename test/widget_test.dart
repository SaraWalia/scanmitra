import 'package:flutter_test/flutter_test.dart';
import 'package:scan_mitra/main.dart';

void main() {
  testWidgets('renders personalized itinerary screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ScanMitraApp());

    expect(find.text('Your Personalized Itinerary'), findsOneWidget);
    expect(find.text('Arrival and Registration'), findsOneWidget);
  });
}
