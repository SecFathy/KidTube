import 'package:flutter_test/flutter_test.dart';
import 'package:safe_tube/main.dart';

void main() {
  testWidgets('App renders SafeTube', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeTubeApp());
    expect(find.text('SafeTube'), findsOneWidget);
  });
}
