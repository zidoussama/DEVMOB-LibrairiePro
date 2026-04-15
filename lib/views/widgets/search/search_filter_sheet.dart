import 'package:flutter/material.dart';

import '../../../../Config/app_colors.dart';
import '../../../../controllers/search_controller.dart';

Future<void> showSearchFilterSheet({
  required BuildContext context,
  required SearchFilters filters,
  required List<String> categories,
  required SearchPriceBounds priceBounds,
  required ValueChanged<SearchFilters> onApply,
}) async {
  final effectiveFilters = filters.clamp(priceBounds);
  final tempSelectedCategories = <String>{...effectiveFilters.categories};
  var tempPriceRange = effectiveFilters.priceRange;
  var tempInStockOnly = effectiveFilters.inStockOnly;
  var tempExpressOnly = effectiveFilters.expressOnly;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFDF8F1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 14,
                  bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Filtres',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      Text(
                        'Prix: ${tempPriceRange.start.round()}€ - ${tempPriceRange.end.round()}€',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      RangeSlider(
                        values: tempPriceRange,
                        min: priceBounds.min,
                        max: priceBounds.max,
                        divisions: priceBounds.divisions,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.primary.withOpacity(0.25),
                        labels: RangeLabels(
                          '${tempPriceRange.start.round()}€',
                          '${tempPriceRange.end.round()}€',
                        ),
                        onChanged: (values) {
                          setModalState(() {
                            tempPriceRange = values;
                          });
                        },
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Catégorie',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (categories.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Aucune catégorie disponible.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: categories.map((category) {
                            final selected = tempSelectedCategories.contains(
                              category,
                            );
                            return _SelectableFilterChip(
                              label: category,
                              selected: selected,
                              onTap: () {
                                setModalState(() {
                                  if (selected) {
                                    tempSelectedCategories.remove(category);
                                  } else {
                                    tempSelectedCategories.add(category);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'Disponibilité',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SelectableFilterChip(
                        label: 'En stock',
                        selected: tempInStockOnly,
                        fullWidth: true,
                        onTap: () {
                          setModalState(() {
                            tempInStockOnly = !tempInStockOnly;
                            if (!tempInStockOnly) {
                              tempExpressOnly = false;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _SelectableFilterChip(
                        label: 'Livraison express',
                        selected: tempExpressOnly,
                        fullWidth: true,
                        onTap: () {
                          setModalState(() {
                            tempExpressOnly = !tempExpressOnly;
                            if (tempExpressOnly) {
                              tempInStockOnly = true;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  tempSelectedCategories.clear();
                                  tempPriceRange = RangeValues(
                                    priceBounds.min,
                                    priceBounds.max,
                                  );
                                  tempInStockOnly = false;
                                  tempExpressOnly = false;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Réinitialiser'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                onApply(
                                  SearchFilters(
                                    priceRange: tempPriceRange,
                                    categories: tempSelectedCategories.toSet(),
                                    inStockOnly: tempInStockOnly,
                                    expressOnly: tempExpressOnly,
                                  ),
                                );
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Appliquer'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _SelectableFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool fullWidth;

  const _SelectableFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.black12,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.text,
        ),
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: child,
    );
  }
}
