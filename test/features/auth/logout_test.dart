import 'package:auto_flow/core/network/token_storage.dart';
import 'package:auto_flow/core/presentation/widget/custom_drawer.dart';
import 'package:auto_flow/core/theme/theme.dart';
import 'package:auto_flow/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:auto_flow/features/auth/presentation/session/session_controller.dart';
import 'package:auto_flow/features/onboarding/presentation/pages/login_page.dart';
import 'package:auto_flow/main.dart' show rootNavigatorKey;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../helpers/memory_secure_storage.dart';
import '../../helpers/test_service_locator.dart';

void main() {
  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await setUpTestServiceLocator();
  });

  Future<SessionController> pumpDrawer(WidgetTester tester) async {
    final session = SessionController(kTestBranchManager);
    await tester.pumpWidget(
      ChangeNotifierProvider<SessionController>.value(
        value: session,
        child: MaterialApp(
          navigatorKey: rootNavigatorKey,
          theme: AppTheme.lightTheme,
          home: const Scaffold(drawer: CustomDrawer(), body: SizedBox()),
        ),
      ),
    );
    final scaffold = tester.firstState<ScaffoldState>(find.byType(Scaffold));
    scaffold.openDrawer();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    return session;
  }

  testWidgets('drawer shows the signed-in user and role', (tester) async {
    await pumpDrawer(tester);
    expect(find.text('Branch Manager'), findsWidgets);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('cancel keeps the session', (tester) async {
    final session = await pumpDrawer(tester);
    await tester.tap(find.text('Logout'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Log out?'), findsOneWidget);

    await tester.tap(find.text('Cancel').last);
    await tester.pump(const Duration(milliseconds: 500));
    expect(session.isSignedIn, isTrue);
    expect(find.byType(LoginPage), findsNothing);
  });

  testWidgets('confirming clears the session and opens Login', (tester) async {
    final session = await pumpDrawer(tester);
    await tester.tap(find.text('Logout'));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Log out').last);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 2));
    expect(session.isSignedIn, isFalse);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  test('clearing discards both tokens and the cached session', () async {
    final storage = MemorySecureStorage();
    final tokens = TokenStorage(storage);
    await tokens.saveTokens(accessToken: 'a', refreshToken: 'r');
    await storage.write(key: 'auth_session', value: '{}');

    await AuthLocalDataSource(tokens, storage).clear();

    expect(await tokens.accessToken, isNull);
    expect(await tokens.refreshToken, isNull);
    expect(storage.data, isEmpty);
  });
}
