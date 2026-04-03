import 'package:flutter/material.dart';

import '../../../Config/app_colors.dart';

class ProductDetailsInfoSection extends StatelessWidget {
  final String categoryLabel;
  final String title;
  final String authorLabel;
  final String publisherLabel;
  final double price;
  final double? oldPrice;
  final int stock;
  final String tagLabel;
  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;
  final String description;
  final String reference;
  final VoidCallback? onAddToCartTap;

  const ProductDetailsInfoSection({
    super.key,
    required this.categoryLabel,
    required this.title,
    required this.authorLabel,
    required this.publisherLabel,
    required this.price,
    this.oldPrice,
    required this.stock,
    required this.tagLabel,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.description,
    required this.reference,
    required this.onAddToCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryLabel,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 28,
              height: 1.05,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            authorLabel,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            publisherLabel,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${price.toStringAsFixed(2)} €',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (oldPrice != null) ...[
                const SizedBox(width: 12),
                Text(
                  '${oldPrice!.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Chip(
                label: 'En stock ($stock)',
                background: AppColors.secondary,
              ),
              _Chip(
                label: tagLabel,
                background: AppColors.primary,
              ),
              _Chip(
                label: 'Livraison 24h',
                background: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _QuantitySelector(
            quantity: quantity,
            onDecrease: onDecrease,
            onIncrease: onIncrease,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAddToCartTap,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('Ajouter au panier'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    disabledBackgroundColor: Colors.black26,
                    disabledForegroundColor: AppColors.surface,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Description',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow(label: 'Éditeur', value: publisherLabel),
          const SizedBox(height: 8),
          _DetailRow(label: 'Auteur', value: authorLabel),
          const SizedBox(height: 8),
          _DetailRow(label: 'Référence', value: reference),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color background;

  const _Chip({required this.label, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.surface,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  const _QuantitySelector({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepperButton(
            icon: Icons.remove,
            onTap: onDecrease,
          ),
          Text(
            quantity.toString(),
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.text),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}