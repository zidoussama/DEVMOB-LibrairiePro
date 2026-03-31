import '../../../Models/product.dart';

String badgeTextFromTag(ProduitModel produit) {
  final tag = produit.tag.trim().toLowerCase();

  if (tag.isEmpty) {
    return produit.stock > 0 ? 'Nouveau' : 'Rupture';
  }

  switch (tag) {
    case 'new':
    case 'nouveau':
      return 'Nouveau';
    case 'promo':
    case 'sale':
    case 'promotion':
    case 'discount':
    case 'soldes':
      return 'Promo';
    case 'rupture':
    case 'out_of_stock':
    case 'out-of-stock':
      return 'Rupture';
    default:
      return produit.tag.trim();
  }
}

bool isSoldTag(ProduitModel produit) {
  final tag = produit.tag.trim().toLowerCase();
  return tag == 'sold' ||
      tag == 'solde' ||
      tag == 'sold-out' ||
      tag == 'sale' ||
      tag == 'promo' ||
      tag == 'promotion' ||
      tag == 'discount' ||
      tag == 'soldes';
}

bool isNewTag(ProduitModel produit) {
  final tag = produit.tag.trim().toLowerCase();
  return tag == 'new' || tag == 'nouveau';
}

bool hasPromotionPrice(ProduitModel produit) {
  return produit.prixPromo > 0;
}
