import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:librairiepro/Config/app_colors.dart';
import 'package:librairiepro/providers/cart_provider.dart';
import 'package:librairiepro/providers/adress_provider.dart';
import 'package:librairiepro/Models/cart.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  final double delivery = 5.99;

  @override
  void initState() {
    super.initState();
    // Fetch carts when page loads
    Future.microtask(
      () {
        context.read<CartProvider>().fetchCarts();
        // Fetch user addresses
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          context.read<AdressProvider>().listenAdresses(userId);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer2<CartProvider, AdressProvider>(
          builder: (context, cartProvider, adressProvider, child) {
            final carts = cartProvider.carts;
            final totalPrice = cartProvider.totalPrice;
            final totalItems = cartProvider.totalItems;
            
            // Get default address
            final defaultAddress = adressProvider.adresses.isNotEmpty
                ? adressProvider.adresses.firstWhere(
                    (addr) => addr.isDefault,
                    orElse: () => adressProvider.adresses.first,
                  )
                : null;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                children: [
                  /// TITLE
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Mon Panier",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("${totalItems} article${totalItems != 1 ? 's' : ''}"),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 20),
                  const SizedBox(height: 8),

                  /// ADDRESS CARD
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _leadingIcon(Icons.location_on_outlined),
                            const SizedBox(width: 8),
                            Text(
                              "Adresse de livraison",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (defaultAddress != null) ...[
                          Text(
                            "${defaultAddress.street ?? ''}\n${defaultAddress.postalCode ?? ''} ${defaultAddress.city ?? ''}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Modifier",
                            style: TextStyle(color: AppColors.primary),
                          )
                        ] else ...[
                          Text(
                            "Aucune adresse définie",
                            style: TextStyle(color: AppColors.text.withOpacity(0.6)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Ajouter une adresse",
                            style: TextStyle(color: AppColors.primary),
                          )
                        ]
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// DELIVERY CARD
                  _card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _leadingIcon(Icons.local_shipping_outlined, tint: AppColors.success),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Livraison Standard",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text("Livraison en 3-5 jours ouvrés"),
                              ],
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text("${delivery.toStringAsFixed(2)} €"),
                            const SizedBox(height: 4),
                            const Text(
                              "Changer",
                              style: TextStyle(color: AppColors.primary),
                            )
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// PRODUCTS LIST
                  if (carts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 60, color: AppColors.text),
                          const SizedBox(height: 16),
                          Text("Votre panier est vide",
                              style: TextStyle(color: AppColors.text)),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (int i = 0; i < carts.length; i++) ...[
                          _productCard(
                            cart: carts[i],
                            provider: cartProvider,
                          ),
                          if (i < carts.length - 1)
                            const SizedBox(height: 12),
                        ],
                      ],
                    ),

                  const SizedBox(height: 12),

                  /// SUMMARY
                  if (carts.isNotEmpty)
                    Column(
                      children: [
                        const Divider(height: 20),
                        _summaryRow("Sous-total", totalPrice),
                        _summaryRow("Livraison", delivery),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            totalPrice + delivery >= 50
                                ? "Livraison gratuite !"
                                : "Plus que ${(50 - (totalPrice + delivery)).toStringAsFixed(2)} € pour la livraison gratuite !",
                            style: TextStyle(
                              color: totalPrice + delivery >= 50
                                  ? AppColors.success
                                  : AppColors.text,
                            ),
                          ),
                        ),
                        const Divider(height: 20),
                        _summaryRow(
                          "Total",
                          totalPrice + delivery,
                          isTotal: true,
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  /// BUTTON
                  if (carts.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle checkout
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Redirection vers le paiement...")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Passer au paiement",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            )
            );
          },
        ),
      ),
    );
  }

  /// PRODUCT CARD
  Widget _productCard({
    required CartModel cart,
    required CartProvider provider,
  }) {
    final product = cart.product;
    
    return _card(
      child: Row(
            children: [
              /// IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.images.isNotEmpty
                    ? Image.network(
                        product.images.first,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            color: AppColors.background,
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: AppColors.background,
                        child: const Icon(Icons.image_not_supported),
                      ),
              ),
              const SizedBox(width: 12),

              /// INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.auteur,
                      style: TextStyle(fontSize: 12, color: AppColors.text.withOpacity(0.75)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.titre,
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 18),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${cart.price.toStringAsFixed(2)} €",
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _showDeleteDialog(context, cart, provider),
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: AppColors.danger),
                          const SizedBox(width: 4),
                          Text(
                            "Supprimer",
                            style: TextStyle(color: AppColors.danger),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              /// QUANTITY
              Container(
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    IconButton(
                      iconSize: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (cart.quantity > 1) {
                          final updated = cart.copyWith(
                            quantity: cart.quantity - 1,
                            totalPrice: cart.price * (cart.quantity - 1),
                          );
                          provider.updateCart(updated);
                        }
                      },
                    ),
                    SizedBox(
                      width: 22,
                      child: Text(
                        cart.quantity.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final updated = cart.copyWith(
                          quantity: cart.quantity + 1,
                          totalPrice: cart.price * (cart.quantity + 1),
                        );
                        provider.updateCart(updated);
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
    );
  }

  /// DELETE CONFIRMATION DIALOG
  void _showDeleteDialog(
    BuildContext context,
    CartModel cart,
    CartProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer du panier"),
        content: Text("Êtes-vous sûr de vouloir supprimer ${cart.product.titre} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              provider.removeFromCart(cart.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Article supprimé du panier")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }

  /// REUSABLE CARD
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.background.withOpacity(0.9)),
      ),
      child: child,
    );
  }

  Widget _leadingIcon(IconData icon, {Color? tint}) {
    return Container(
      height: 34,
      width: 34,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(icon, size: 18, color: tint ?? AppColors.text.withOpacity(0.75)),
    );
  }

  /// SUMMARY ROW
  Widget _summaryRow(String title, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: AppColors.text,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
        Text(
          "${value.toStringAsFixed(2)} €",
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: AppColors.text,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }
}