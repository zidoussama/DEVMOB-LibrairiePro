import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'shoppingcart.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    Center(child: Text("Recherche")),
    ShoppingCartPage(),
    Center(child: Text("Favoris")),
    Center(child: Text("Compte")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}