import 'package:flutter_test/flutter_test.dart';
import 'package:sahhef/main.dart';

void main() {
  testWidgets('SahhefApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SahhefApp());
    expect(find.byType(SahhefApp), findsOneWidget);
  });
}
