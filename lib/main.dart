import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/splash/splash_screen.dart';
import 'package:provider/provider.dart';

import 'login/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      builder: (context, c) {
        ThemeProvider themeProvider = context.watch();
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          home: SplashScreen(),
        );
      },
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = ThemeData.dark();

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    _currentTheme = _currentTheme == ThemeData.light()
        ? ThemeData.dark()
        : ThemeData.light();
    notifyListeners();
  }
}
