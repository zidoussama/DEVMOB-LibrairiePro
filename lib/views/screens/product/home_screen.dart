import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/produit_provider.dart';
import '../../../../Config/app_colors.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/home_products_section.dart';
import '../../widgets/home/home_promo_banner.dart';
import '../../widgets/home/home_search_bar.dart';
import '../../widgets/home/home_sold_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProduitProvider>().listenProduits();
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                title: 'LibrairiePro',
                greeting: 'Bonjour, Marie 👋',
                onNotificationTap: () {},
              ),
              const SizedBox(height: 16),

              HomeSearchBar(
                hintText: 'Rechercher un livre...',
                onTap: () {},
                onChanged: (_) {},
              ),
              const SizedBox(height: 18),

              const HomePromoBanner(),
              const SizedBox(height: 22),

              HomeSoldSection(onSeeAllTap: () {}),
              const SizedBox(height: 22),

              HomeProductsSection(onSeeAllTap: () {}),
            ],
          ),
        ),
      ),

      // Bottom nav like screenshot
    );
  }
}
