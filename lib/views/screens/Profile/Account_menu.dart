import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../Config/app_colors.dart';
import '../../../providers/Like_Provider.dart';

class AccountMenu extends StatefulWidget {
  const AccountMenu({super.key});

  @override
  State<AccountMenu> createState() => _AccountMenuState();
}

class _AccountMenuState extends State<AccountMenu> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur déconnexion: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: user == null
            ? const _NotLoggedInWidget()
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Mon Compte',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Profile card
                    _ProfileCard(user: user),
                    const SizedBox(height: 24),

                    // Menu items
                    _MenuItem(
                      icon: Icons.person_outline,
                      title: 'Informations personnelles',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Adresses sauvegardées',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.local_shipping_outlined,
                      title: 'Historique des commandes',
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),

                    // Stats
                    _StatsSection(),
                    const SizedBox(height: 28),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoggingOut ? null : _handleLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8B4B8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoggingOut
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout, color: Colors.redAccent),
                                  SizedBox(width: 8),
                                  Text(
                                    'Déconnexion',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final User user;

  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName ?? 'Utilisateur';
    final email = user.email ?? 'email@example.com';
    final phoneNumber = user.phoneNumber ?? '+33 6 12 34 56 78';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6B5850),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white30,
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),

              // Name and email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),

          // Email row
          Row(
            children: [
              const Icon(
                Icons.mail_outline,
                size: 20,
                color: Colors.white70,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Phone row
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 20,
                color: Colors.white70,
              ),
              const SizedBox(width: 12),
              Text(
                phoneNumber,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bordor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.text,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<LikeProvider>(
      builder: (context, likeProvider, _) {
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                count: '12',
                label: 'Commandes',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                count: '${likeProvider.likedProductsCount}',
                label: 'Favoris',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                count: '.....',
                label: '......',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String count;
  final String label;

  const _StatCard({
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordor),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.text,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotLoggedInWidget extends StatelessWidget {
  const _NotLoggedInWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Non connecté',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Connectez-vous pour accéder à votre compte',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Se connecter',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
