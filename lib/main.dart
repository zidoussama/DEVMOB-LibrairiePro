import 'package:flutter/material.dart';
import '../config/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LibrairiePro',
      theme: ThemeData(
        primaryColor: const Color(0xFF6B4F3B),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.getRoutes(),
    );
  }
}