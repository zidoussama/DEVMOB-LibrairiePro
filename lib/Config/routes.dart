import 'package:flutter/material.dart';
import '../views/screens/auth/login_screen.dart';
import '../views/screens/auth/register_screen.dart';
import '../views/screens/main_page.dart';
import '../views/screens/splash_screen.dart';
import '../views/screens/splash_static_screen.dart';

class AppRoutes {
  static const String splashStatic = '/splash-static';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splashStatic: (context) => const SplashStaticScreen(),
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      main: (context) => const MainPage(),
    };
  }

  static const String initialRoute = splashStatic;
}
