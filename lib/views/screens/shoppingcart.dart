import 'package:flutter/material.dart';
import 'package:librairiepro/Config/app_colors.dart';


class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  int quantity = 1;
  int currentIndex = 2;

  double get subtotal => 12.99 * quantity;
  double delivery = 5.99;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("1 article"),
              ),
              const SizedBox(height: 20),

              /// ADDRESS CARD
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined),
                        SizedBox(width: 8),
                        Text(
                          "Adresse de livraison",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text("123 Rue de la Paix, 75001 Paris"),
                    const SizedBox(height: 6),
                    Text(
                      "Modifier",
                      style: TextStyle(color: AppColors.primary),
                    )
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
                      children: const [
                        Icon(Icons.local_shipping_outlined),
                        SizedBox(width: 8),
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
                      children: const [
                        Text("5.99 €"),
                        SizedBox(height: 4),
                        Text(
                          "Changer",
                          style: TextStyle(color: AppColors.primary),
                        )
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// PRODUCT CARD
              _card(
                child: Row(
                  children: [
                    /// IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/book.jpg", // change to your asset
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// INFO
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Antoine de Saint-Exupéry",
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Le Petit Prince",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("${subtotal.toStringAsFixed(2)} €"),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  color: AppColors.danger),
                              const SizedBox(width: 4),
                              Text(
                                "Supprimer",
                                style:
                                    TextStyle(color: AppColors.danger),
                              )
                            ],
                          )
                        ],
                      ),
                    ),

                    /// QUANTITY
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (quantity > 1) {
                                setState(() => quantity--);
                              }
                            },
                          ),
                          Text(quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() => quantity++);
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const Spacer(),

              /// SUMMARY
              Column(
                children: [
                  _summaryRow("Sous-total", subtotal),
                  _summaryRow("Livraison", delivery),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Plus que 37.01 € pour la livraison gratuite !",
                      style: TextStyle(color: AppColors.success),
                    ),
                  ),
                  const Divider(height: 20),
                  _summaryRow(
                    "Total",
                    subtotal + delivery,
                    isTotal: true,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
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
        ),
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
      ),
      child: child,
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
          ),
        ),
        Text(
          "${value.toStringAsFixed(2)} €",
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }
}