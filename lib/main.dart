import 'package:ej_geek/core/presentation/pages/splash_screen.dart';
import 'package:ej_geek/core/theme/theme.dart';
import 'package:ej_geek/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = await ThemeController.create();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, _) {
        return MaterialApp(
          title: 'E&J Geek Invoice',
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
