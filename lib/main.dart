import 'package:auto_flow/core/di/service_locator.dart';
import 'package:auto_flow/core/presentation/pages/splash_screen.dart';
import 'package:auto_flow/core/theme/theme.dart';
import 'package:auto_flow/core/theme/theme_controller.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:auto_flow/features/search/presentation/bloc/search_bloc.dart';
import 'dart:async';

import 'package:auto_flow/core/network/session_expiry.dart';
import 'package:auto_flow/features/auth/presentation/session/session_controller.dart';
import 'package:auto_flow/features/onboarding/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  setupServiceLocator();
  final themeController = await ThemeController.create();

  runApp(
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
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<void>? _expirySub;
  late final SessionController _session;

  @override
  void initState() {
    super.initState();
    _session = context.read<SessionController>();
    // Refresh token rejected -> clear the session and return to Login.
    _expirySub = sl<SessionExpiry>().stream.listen((_) {
      _session.clear();
      rootNavigatorKey.currentState?.pushAndRemoveUntil(
        LoginPage.route(),
        (_) => false,
      );
    });
  }

  @override
  void dispose() {
    _expirySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, _) {
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'AutoFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          initialRoute: SplashScreen.routeName,
          home: const SplashScreen(),
        );
      },
    );
  }
}
