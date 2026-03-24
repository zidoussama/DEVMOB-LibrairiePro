import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/product_card.dart';
import '../../Config/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    const bg = AppColors.background;
    const darkText = AppColors.text;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar: title + greeting + notification
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "LibrairiePro",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Bonjour, Marie 👋",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _NotificationButton(
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search field
              _SearchBar(
                hintText: "Rechercher un livre...",
                onTap: () {},
                onChanged: (_) {},
              ),
              const SizedBox(height: 18),

              // Promo banner (carousel-like)
              const _PromoBanner(),
              const SizedBox(height: 22),

              // Section header: Nouveautés
              Row(
                children: [
                  const Text(
                    "Nouveautés",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Voir tout",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Products horizontal list
              SizedBox(
                height: 290,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final isFirst = index == 0;
                    return ProductCard(
                      title: isFirst
                          ? "Collectif\nMathématiques\n1ère Terminale"
                          : "Kit de Géométrie",
                      imageUrl: "", // add your url later
                      price: isFirst ? 32.50 : 8.99,
                      rating: 4,
                      reviewCount: isFirst ? 89 : 156,
                      badgeText: "Nouveau",
                      isFavorite: false,
                      onTap: () {},
                      onFavoriteTap: () {},
                      onAddToCartTap: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom nav like screenshot
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NotificationButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: AppColors.background, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const _SearchBar({
    required this.hintText,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black26),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    // Simple static banner that looks like a carousel card.
    // Later you can replace with PageView + dots indicator.
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF2F4F3E), // dark green-ish overlay color
        image: const DecorationImage(
          // Replace with your asset later: AssetImage('assets/banner.jpg')
          image: NetworkImage(
            'https://images.unsplash.com/photo-1519682337058-a94d519337bc?auto=format&fit=crop&w=1400&q=60',
          ),
          fit: BoxFit.cover,
          opacity: 0.90,
        ),
      ),
      child: Stack(
        children: [
          // Dark overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.12),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Rentrée Scolaire",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Jusqu'à -30% sur les manuels",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow button
                Material(
                  color: Colors.white.withOpacity(0.22),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dots (static)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Dot(active: true),
                _Dot(active: false),
                _Dot(active: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white60,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}