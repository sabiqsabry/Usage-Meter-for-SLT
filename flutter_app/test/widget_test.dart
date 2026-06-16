import 'package:flutter_test/flutter_test.dart';
import 'package:slt_usage_meter/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const SltUsageMeterApp());
    expect(find.byType(SltUsageMeterApp), findsOneWidget);
  });
}
