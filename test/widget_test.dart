import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pocketplan/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PocketPlan shows the four starter tasks on first launch',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PocketPlanApp());
    await tester.pumpAndSettle();

    expect(find.text('Algebra'), findsOneWidget);
    expect(find.text('Read brief'), findsOneWidget);
    expect(find.text('Python exercises'), findsOneWidget);
    expect(find.text('Revise notes'), findsOneWidget);
  });
}
