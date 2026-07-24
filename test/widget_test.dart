import 'package:flutter_test/flutter_test.dart';
import 'package:mediquick/main.dart';

void main() {
  testWidgets('MediQuick app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MediQuick());
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(MediQuick), findsOneWidget);
  });
}
