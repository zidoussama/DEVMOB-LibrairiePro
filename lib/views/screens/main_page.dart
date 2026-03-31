import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'product/home_screen.dart';
import 'shoppingcart.dart';
import 'favorite/favo_screen.dart';
import 'Profile/Account_menu.dart';

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
    FavoScreen(),
    AccountMenu(),
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