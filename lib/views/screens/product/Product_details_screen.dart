import 'package:flutter/material.dart';

import '../../../../Config/app_colors.dart';
import '../../../../Models/product.dart';

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
	late final PageController _pageController;
	late final List<String> _images;
	int _currentImageIndex = 0;
	int _quantity = 1;

	@override
	void initState() {
		super.initState();
		_pageController = PageController();
		_images = widget.product.images
				.where((image) => image.trim().isNotEmpty)
				.toList();
		if (_images.isEmpty) {
			_images.add('');
		}
	}

	@override
	void dispose() {
		_pageController.dispose();
		super.dispose();
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
						Padding(
							padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									_IconCircleButton(
										icon: Icons.arrow_back,
										onTap: () => Navigator.of(context).maybePop(),
									),
									_IconCircleButton(
										icon: widget.isFavorite
												? Icons.favorite
												: Icons.favorite_border,
										onTap: widget.onFavoriteTap,
										iconColor:
												widget.isFavorite ? Colors.redAccent : AppColors.text,
									),
								],
							),
						),
						Expanded(
							child: SingleChildScrollView(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Padding(
											padding: const EdgeInsets.symmetric(horizontal: 16),
											child: ClipRRect(
												borderRadius: BorderRadius.circular(22),
												child: AspectRatio(
													aspectRatio: 0.94,
													child: Stack(
														children: [
															PageView.builder(
																controller: _pageController,
																itemCount: _images.length,
																onPageChanged: (index) {
																	setState(() => _currentImageIndex = index);
																},
																itemBuilder: (context, index) {
																	final imageUrl = _images[index];
																	return _ProductImage(imageUrl: imageUrl);
																},
															),
															if (_images.length > 1) ...[
																Positioned(
																	left: 12,
																	top: 0,
																	bottom: 0,
																	child: _GalleryArrowButton(
																		icon: Icons.chevron_left,
																		onTap: () {
																			if (_currentImageIndex <= 0) return;
																			_pageController.previousPage(
																				duration:
																						const Duration(milliseconds: 250),
																				curve: Curves.easeOut,
																			);
																		},
																	),
																),
																Positioned(
																	right: 12,
																	top: 0,
																	bottom: 0,
																	child: _GalleryArrowButton(
																		icon: Icons.chevron_right,
																		onTap: () {
																			if (_currentImageIndex >= _images.length - 1) {
																				return;
																			}
																			_pageController.nextPage(
																				duration:
																						const Duration(milliseconds: 250),
																				curve: Curves.easeOut,
																			);
																		},
																	),
																),
															],
															if (_hasPromotion)
																const Positioned(
																	top: 14,
																	left: 14,
																	child: _Badge(label: 'Nouveau'),
																),
															Positioned(
																top: 52,
																left: 14,
																child: _Badge(
																	label: product.stock > 0
																			? 'Livraison Express'
																			: 'Rupture de stock',
																),
															),
															Positioned(
																bottom: 14,
																left: 0,
																right: 0,
																child: Row(
																	mainAxisAlignment: MainAxisAlignment.center,
																	children: List.generate(_images.length, (index) {
																		final selected = index == _currentImageIndex;
																		return AnimatedContainer(
																			duration:
																					const Duration(milliseconds: 200),
																			margin: const EdgeInsets.symmetric(
																				horizontal: 4,
																			),
																			width: selected ? 18 : 7,
																			height: 7,
																			decoration: BoxDecoration(
																				color: selected
																						? AppColors.surface
																						: AppColors.surface.withOpacity(0.55),
																				borderRadius: BorderRadius.circular(99),
																			),
																		);
																	}),
																),
															),
														],
													),
												),
											),
										),
										Padding(
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
														product.titre,
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
																'${_effectivePrice.toStringAsFixed(2)} €',
																style: const TextStyle(
																	color: AppColors.text,
																	fontSize: 26,
																	fontWeight: FontWeight.w800,
																),
															),
															if (_hasPromotion) ...[
																const SizedBox(width: 12),
																Text(
																	'${product.prix.toStringAsFixed(2)} €',
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
																label: 'En stock (${product.stock})',
																background: AppColors.secondary,
															),
															_Chip(
																label: product.tag.isNotEmpty
																		? product.tag
																		: 'Disponible',
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
														quantity: _quantity,
														onDecrease: _quantity > 1
																? () => setState(() => _quantity--)
																: null,
														onIncrease: () => setState(() => _quantity++),
													),
													const SizedBox(height: 18),
													Row(
														children: [
															Expanded(
																child: ElevatedButton.icon(
																	onPressed: product.stock <= 0
																			? null
																			: widget.onAddToCartTap,
																	icon: const Icon(Icons.shopping_cart_outlined),
																	label: const Text('Ajouter au panier'),
																	style: ElevatedButton.styleFrom(
																		backgroundColor: AppColors.primary,
																		foregroundColor: AppColors.surface,
																		disabledBackgroundColor: Colors.black26,
																		disabledForegroundColor: AppColors.surface,
																		elevation: 0,
																		padding: const EdgeInsets.symmetric(
																			vertical: 16,
																		),
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
														product.description.isNotEmpty
																? product.description
																: 'Aucune description n\'est disponible pour ce produit.',
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
													_DetailRow(label: 'Référence', value: product.uid),
													const SizedBox(height: 24),
												],
											),
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

class _IconCircleButton extends StatelessWidget {
	final IconData icon;
	final VoidCallback? onTap;
	final Color iconColor;

	const _IconCircleButton({
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

class _GalleryArrowButton extends StatelessWidget {
	final IconData icon;
	final VoidCallback onTap;

	const _GalleryArrowButton({required this.icon, required this.onTap});

	@override
	Widget build(BuildContext context) {
		return Align(
			alignment: Alignment.center,
			child: Material(
				color: AppColors.surface.withOpacity(0.9),
				shape: const CircleBorder(),
				child: IconButton(
					onPressed: onTap,
					icon: Icon(icon, color: AppColors.text),
				),
			),
		);
	}
}

class _Badge extends StatelessWidget {
	final String label;

	const _Badge({required this.label});

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
			decoration: BoxDecoration(
				color: AppColors.secondary.withOpacity(0.9),
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

class _ProductImage extends StatelessWidget {
	final String imageUrl;

	const _ProductImage({required this.imageUrl});

	@override
	Widget build(BuildContext context) {
		if (imageUrl.trim().isEmpty) {
			return Container(
				color: const Color(0xFFD9C8B8),
				alignment: Alignment.center,
				child: const Icon(
					Icons.menu_book_rounded,
					size: 92,
					color: Colors.white70,
				),
			);
		}

		return Image.network(
			imageUrl,
			fit: BoxFit.cover,
			errorBuilder: (_, __, ___) {
				return Container(
					color: const Color(0xFFD9C8B8),
					alignment: Alignment.center,
					child: const Icon(
						Icons.menu_book_rounded,
						size: 92,
						color: Colors.white70,
					),
				);
			},
			loadingBuilder: (context, child, loadingProgress) {
				if (loadingProgress == null) return child;
				return Container(
					color: const Color(0xFFD9C8B8),
					alignment: Alignment.center,
					child: const CircularProgressIndicator(),
				);
			},
		);
	}
}
