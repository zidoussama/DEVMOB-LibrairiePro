import 'package:flutter/material.dart';
import '../views/screens/login_screen.dart';
import '../views/screens/register_screen.dart';
import '../views/screens/main_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      main: (context) => const MainPage(),
    };
  }

  static const String initialRoute = login;
}