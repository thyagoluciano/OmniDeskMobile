import 'package:flutter_test/flutter_test.dart';
import 'package:omnidesk_mobile/main.dart';

void main() {
  testWidgets('OmniDesk app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OmniDeskApp());
    expect(find.text('OmniDesk'), findsOneWidget);
    expect(find.text('Computadores'), findsOneWidget);
    expect(find.text('Transferências'), findsOneWidget);
  });
}
