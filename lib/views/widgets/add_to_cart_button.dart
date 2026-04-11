import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:librairiepro/Models/cart.dart';
import 'package:librairiepro/Models/product.dart';
import 'package:librairiepro/Config/app_colors.dart';
import 'package:librairiepro/providers/cart_provider.dart';

class AddToCartButton extends StatefulWidget {
  final ProduitModel product;
  final VoidCallback? onSuccess;

  const AddToCartButton({
    super.key,
    required this.product,
    this.onSuccess,
  });

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  int quantity = 1;
  bool isLoading = false;

  Future<void> _addToCart(CartProvider cartProvider) async {
    setState(() => isLoading = true);

    try {
      final cart = CartModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: widget.product,
        price: widget.product.prixPromo > 0
            ? widget.product.prixPromo
            : widget.product.prix,
        quantity: quantity,
        totalPrice: (widget.product.prixPromo > 0
                ? widget.product.prixPromo
                : widget.product.prix) *
            quantity,
      );

      final success = await cartProvider.addToCart(cart);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$quantity ${quantity > 1 ? "articles" : "article"} ajouté au panier",
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        widget.onSuccess?.call();
        setState(() => quantity = 1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              cartProvider.errorMessage ?? "Erreur lors de l'ajout au panier",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Column(
          children: [
            /// QUANTITY SELECTOR
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      iconSize: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      icon: const Icon(Icons.remove),
                      onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                    ),
                    SizedBox(
                      width: 20,
                      child: Text(
                        quantity.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => quantity++),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            /// ADD TO CART BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _addToCart(cartProvider),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Ajouter au panier",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
