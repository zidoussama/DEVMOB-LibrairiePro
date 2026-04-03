import 'package:flutter/material.dart';

import '../../../../Config/app_colors.dart';
import '../../../../Models/product.dart';
import 'package:librairiepro/views/widgets/product_details/product_details_app_bar.dart';
import 'package:librairiepro/views/widgets/product_details/product_details_gallery.dart';
import 'package:librairiepro/views/widgets/product_details/product_details_info_section.dart';

class ProductDetailsScreen extends StatefulWidget {
	final ProduitModel product;
	final bool isFavorite;
	final VoidCallback? onFavoriteTap;
	final VoidCallback? onAddToCartTap;

	const ProductDetailsScreen({
		super.key,
		required this.product,
		this.isFavorite = false,
		this.onFavoriteTap,
		this.onAddToCartTap,
	});

	@override
	State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
	late final List<String> _images;
	late bool _isFavorite;
	int _currentImageIndex = 0;
	int _quantity = 1;

	@override
	void initState() {
		super.initState();
		_images = widget.product.images
				.where((image) => image.trim().isNotEmpty)
				.toList();
		if (_images.isEmpty) {
			_images.add('');
		}
		_isFavorite = widget.isFavorite;
	}

	@override
	void didUpdateWidget(covariant ProductDetailsScreen oldWidget) {
		super.didUpdateWidget(oldWidget);
		if (oldWidget.isFavorite != widget.isFavorite) {
			_isFavorite = widget.isFavorite;
		}
	}

	double get _effectivePrice =>
			widget.product.prixPromo > 0 ? widget.product.prixPromo : widget.product.prix;

	bool get _hasPromotion =>
			widget.product.prixPromo > 0 && widget.product.prixPromo < widget.product.prix;

	@override
	Widget build(BuildContext context) {
		final product = widget.product;
		final authorLabel = product.auteur.isNotEmpty ? product.auteur : 'Auteur inconnu';
		final publisherLabel = product.editeur.isNotEmpty ? product.editeur : 'Éditeur non renseigné';
		final categoryLabel = product.categorie?.name.isNotEmpty == true
				? product.categorie!.name
				: (product.tag.isNotEmpty ? product.tag : 'Collectif');

		return Scaffold(
			backgroundColor: AppColors.background,
			body: SafeArea(
				child: Column(
					children: [
						ProductDetailsAppBar(
							isFavorite: _isFavorite,
							onBackTap: () => Navigator.of(context).maybePop(),
							onFavoriteTap: widget.onFavoriteTap == null
									? null
									: () {
											setState(() {
												_isFavorite = !_isFavorite;
											});
											widget.onFavoriteTap?.call();
										},
						),
						Expanded(
							child: SingleChildScrollView(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										ProductDetailsGallery(
											imageUrls: _images,
											currentIndex: _currentImageIndex,
											showNewBadge: _hasPromotion,
											stockLabel:
													product.stock > 0 ? 'Livraison Express' : 'Rupture de stock',
											onPageChanged: (index) {
												setState(() => _currentImageIndex = index);
											},
										),
										ProductDetailsInfoSection(
											categoryLabel: categoryLabel,
											title: product.titre,
											authorLabel: authorLabel,
											publisherLabel: publisherLabel,
											price: _effectivePrice,
											oldPrice: _hasPromotion ? product.prix : null,
											stock: product.stock,
											tagLabel: product.tag.isNotEmpty ? product.tag : 'Disponible',
											quantity: _quantity,
											onDecrease: _quantity > 1
													? () => setState(() => _quantity--)
													: null,
											onIncrease: () => setState(() => _quantity++),
											description: product.description.isNotEmpty
													? product.description
													: 'Aucune description n\'est disponible pour ce produit.',
											reference: product.uid,
											onAddToCartTap: product.stock <= 0
													? null
													: widget.onAddToCartTap,
										),
									],
								),
							),
						),
					],
				),
			),
		);
	}
}
