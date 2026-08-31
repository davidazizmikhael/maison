import 'package:flutter_test/flutter_test.dart';
import 'package:maison/main.dart';

void main() {
  testWidgets('Onboarding renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaisonApp());
    expect(find.textContaining('Maison files it'), findsOneWidget);
  });
}
