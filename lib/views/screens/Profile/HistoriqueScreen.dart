import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Config/app_colors.dart';
import '../../../Models/command.dart';
import '../../../providers/command_provider.dart';

class CommandHistoryScreen extends StatefulWidget {
  const CommandHistoryScreen({super.key});

  @override
  State<CommandHistoryScreen> createState() => _CommandHistoryScreenState();
}

class _CommandHistoryScreenState extends State<CommandHistoryScreen> {
  final List<_CommandFilter> _filters = const [
    _CommandFilter(label: 'Toutes', value: 'all'),
    _CommandFilter(label: 'En attente', value: 'pending'),
    _CommandFilter(label: 'En préparation', value: 'preparing'),
    _CommandFilter(label: 'Livrée', value: 'delivered'),
  ];

  String _selectedFilter = 'all';
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasLoaded) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<CommandProvider>().listenCommands(user.uid);
    }
    _hasLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Historique des commandes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        height: 1.05,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final selected = _selectedFilter == filter.value;
                    return _FilterChip(
                      label: filter.label,
                      selected: selected,
                      onTap: () => setState(() => _selectedFilter = filter.value),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: user == null
                  ? _EmptyState(
                      icon: Icons.lock_outline,
                      title: 'Connexion requise',
                      message: 'Connectez-vous pour voir votre historique de commandes.',
                    )
                  : Consumer<CommandProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading && provider.commands.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          );
                        }

                        if (provider.error != null && provider.commands.isEmpty) {
                          return _EmptyState(
                            icon: Icons.error_outline,
                            title: 'Impossible de charger les commandes',
                            message: provider.error ?? 'Une erreur est survenue.',
                          );
                        }

                        final filteredCommands = provider.commands.where((command) {
                          return _matchesFilter(command, _selectedFilter);
                        }).toList();

                        if (filteredCommands.isEmpty) {
                          return const _EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'Aucune commande',
                            message: 'Aucune commande ne correspond à ce filtre.',
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: filteredCommands.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final command = filteredCommands[index];
                            return _CommandCard(command: command);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(CommandModel command, String filter) {
    if (filter == 'all') return true;

    final status = _normalizedStatus(command.status);
    if (filter == 'pending') {
      return status == 'pending' || status == 'paid' || status == 'confirmed';
    }
    if (filter == 'preparing') {
      return status == 'preparing' || status == 'processing' || status == 'en préparation';
    }
    if (filter == 'delivered') {
      return status == 'delivered' || status == 'shipped' || status == 'expédiée' || status == 'livrée';
    }
    return true;
  }

  String _normalizedStatus(String value) {
    return value.trim().toLowerCase();
  }
}

class _CommandCard extends StatelessWidget {
  final CommandModel command;

  const _CommandCard({required this.command});

  @override
  Widget build(BuildContext context) {
    final status = _displayStatus(command.status);
    final statusStyle = _statusStyle(command.status);
    final createdAt = command.createdAt;
    final dateLabel = createdAt == null
        ? 'Date inconnue'
        : '${createdAt.day} ${_monthName(createdAt.month)} ${createdAt.year}';
    final commandLabel = _commandLabel(command);
    final itemCount = command.items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.bordor.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: statusStyle.background,
                shape: BoxShape.circle,
              ),
              child: Icon(statusStyle.icon, size: 18, color: statusStyle.foreground),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          commandLabel,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(label: status, style: statusStyle),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(icon: Icons.calendar_today_outlined, text: dateLabel),
                  const SizedBox(height: 4),
                  _InfoRow(icon: Icons.local_shipping_outlined, text: '$itemCount article${itemCount > 1 ? 's' : ''}'),
                  const SizedBox(height: 6),
                  Text(
                    '${command.total.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.text.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  String _commandLabel(CommandModel command) {
    if (command.id.isEmpty) return 'Commande';
    final shortId = command.id.length > 4 ? command.id.substring(command.id.length - 4) : command.id;
    final year = command.createdAt?.year ?? DateTime.now().year;
    return 'LP-$year-$shortId';
  }

  String _displayStatus(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'paid' || normalized == 'pending' || normalized == 'confirmed') {
      return 'En attente';
    }
    if (normalized == 'preparing' || normalized == 'processing' || normalized == 'en préparation') {
      return 'En préparation';
    }
    if (normalized == 'shipped' || normalized == 'expédiée') {
      return 'Expédiée';
    }
    if (normalized == 'delivered' || normalized == 'livrée') {
      return 'Livrée';
    }
    return value.isEmpty ? 'En attente' : value;
  }

  _StatusStyle _statusStyle(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'paid' || normalized == 'pending' || normalized == 'confirmed') {
      return _StatusStyle(
        foreground: const Color(0xFF8A5B2E),
        background: const Color(0xFFFFF0DA),
        icon: Icons.inventory_2_outlined,
      );
    }
    if (normalized == 'preparing' || normalized == 'processing' || normalized == 'en préparation') {
      return _StatusStyle(
        foreground: const Color(0xFF4D6FD6),
        background: const Color(0xFFE6EEFF),
        icon: Icons.local_shipping_outlined,
      );
    }
    if (normalized == 'shipped' || normalized == 'expédiée') {
      return _StatusStyle(
        foreground: const Color(0xFF2F6D4F),
        background: const Color(0xFFE1F3EA),
        icon: Icons.local_shipping_outlined,
      );
    }
    if (normalized == 'delivered' || normalized == 'livrée') {
      return _StatusStyle(
        foreground: const Color(0xFF2F6D4F),
        background: const Color(0xFFE1F3EA),
        icon: Icons.verified_outlined,
      );
    }
    return _StatusStyle(
      foreground: AppColors.primary,
      background: const Color(0xFFF1E7DA),
      icon: Icons.inventory_2_outlined,
    );
  }

  String _monthName(int month) {
    const months = <String>[
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.text.withOpacity(0.6)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.text.withOpacity(0.72),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final _StatusStyle style;

  const _StatusChip({required this.label, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: style.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFF4EADF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.text.withOpacity(0.75),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF1E7DA),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 34),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text.withOpacity(0.7),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommandFilter {
  final String label;
  final String value;

  const _CommandFilter({required this.label, required this.value});
}

class _StatusStyle {
  final Color foreground;
  final Color background;
  final IconData icon;

  const _StatusStyle({
    required this.foreground,
    required this.background,
    required this.icon,
  });
}