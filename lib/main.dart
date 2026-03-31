import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/Like_Provider.dart';
import 'providers/produit_provider.dart';
import 'Config/routes.dart';
import '../../Config/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProduitProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LibrairiePro',
        theme: ThemeData(primaryColor: AppColors.primary, useMaterial3: true),
        initialRoute: AppRoutes.initialRoute,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
