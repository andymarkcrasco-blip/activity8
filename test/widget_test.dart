import 'package:flutter_test/flutter_test.dart';
import 'package:activity8/app.dart';

void main() {
  testWidgets('Activity8 app boots with Home navigation shell', (tester) async {
    await tester.pumpWidget(const Activity8App());
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Activity 8!'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Login'), findsWidgets);
  });
}
