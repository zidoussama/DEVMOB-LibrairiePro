import 'package:flutter/material.dart';

import '../../../Config/app_colors.dart';

class ProductDetailsAppBar extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onBackTap;
  final VoidCallback? onFavoriteTap;

  const ProductDetailsAppBar({
    super.key,
    required this.isFavorite,
    required this.onBackTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back,
            onTap: onBackTap,
          ),
          _CircleIconButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            iconColor: isFavorite ? Colors.redAccent : AppColors.text,
            onTap: onFavoriteTap,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.text,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 1,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: iconColor),
      ),
    );
  }
}