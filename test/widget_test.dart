import 'package:flutter_test/flutter_test.dart';

import 'package:khangmate_ui/main.dart';
import 'package:khangmate_ui/screens/splash_screen.dart';
import 'package:khangmate_ui/routes.dart';

void main() {
  testWidgets('App builds and shows splash screen', (WidgetTester tester) async {
    // Wrap MaterialApp with a custom onGenerateRoute for testing
    await tester.pumpWidget(
      KhangMateApp(
        routesOverride: {
          Routes.splash: (_) => SplashScreen(onTimeout: () {}),
        },
      ),
    );

    // Pump frames to allow the widget tree to build
    await tester.pumpAndSettle();

    // Verify SplashScreen is displayed
    expect(find.byType(SplashScreen), findsOneWidget);

    // Optional: check for app title text (if SplashScreen shows it)
    expect(find.text('KhangMate'), findsOneWidget);
  });
}
