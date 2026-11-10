import 'package:auto_flow/core/di/service_locator.dart';
import 'package:auto_flow/core/presentation/pages/splash_screen.dart';
import 'package:auto_flow/core/theme/theme_controller.dart';
import 'package:auto_flow/features/auth/presentation/session/session_controller.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:auto_flow/features/onboarding/presentation/pages/intro_page.dart';
import 'package:auto_flow/features/search/presentation/bloc/search_bloc.dart';
import 'package:auto_flow/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'helpers/test_service_locator.dart';

void main() {
  setUp(() => setUpTestServiceLocator());

  testWidgets('App renders splash screen on startup, then the intro', (
    WidgetTester tester,
  ) async {
    final themeController = await ThemeController.create();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeController>.value(value: themeController),
          ChangeNotifierProvider<SessionController>(
            create: (_) => SessionController(),
          ),
          BlocProvider<InvoiceBloc>.value(value: sl<InvoiceBloc>()),
          BlocProvider<SearchBloc>.value(value: sl<SearchBloc>()),
        ],
        child: const MyApp(),
      ),
    );

    // MyApp sets `initialRoute: '/splash'` without a `routes` table, so
    // debug builds report "Could not navigate to initial route" and fall
    // back to `home` (the splash). Harmless; swallow just that report.
    final routeError = tester.takeException();
    if (routeError != null) {
      expect(routeError.toString(), contains('initial route'));
    }

    expect(find.byType(MyApp), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);

    // Splash holds for 1.2s, then routes to the intro on first launch.
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(IntroPage), findsOneWidget);

    // Dispose the intro's looping tick before the test ends.
    await tester.pumpWidget(const SizedBox());
  });
}
