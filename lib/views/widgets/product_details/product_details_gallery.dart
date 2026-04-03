import 'package:flutter/material.dart';

import '../../../Config/app_colors.dart';

class ProductDetailsGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int currentIndex;
  final bool showNewBadge;
  final String stockLabel;
  final ValueChanged<int> onPageChanged;

  const ProductDetailsGallery({
    super.key,
    required this.imageUrls,
    required this.currentIndex,
    required this.showNewBadge,
    required this.stockLabel,
    required this.onPageChanged,
  });

  @override
  State<ProductDetailsGallery> createState() => _ProductDetailsGalleryState();
}

class _ProductDetailsGalleryState extends State<ProductDetailsGallery> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.currentIndex);
  }

  @override
  void didUpdateWidget(covariant ProductDetailsGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex &&
        _controller.hasClients &&
        _controller.page?.round() != widget.currentIndex) {
      _controller.jumpToPage(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: AspectRatio(
          aspectRatio: 0.94,
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: widget.imageUrls.length,
                onPageChanged: widget.onPageChanged,
                itemBuilder: (context, index) {
                  return _ProductNetworkImage(url: widget.imageUrls[index]);
                },
              ),
              if (widget.imageUrls.length > 1) ...[
                Positioned(
                  left: 12,
                  top: 0,
                  bottom: 0,
                  child: _GalleryArrowButton(
                    icon: Icons.chevron_left,
                    onTap: widget.currentIndex <= 0
                        ? null
                        : () {
                            _controller.previousPage(
                              duration: const Duration(milliseconds: 250),
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
                    onTap: widget.currentIndex >= widget.imageUrls.length - 1
                        ? null
                        : () {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          },
                  ),
                ),
              ],
              if (widget.showNewBadge)
                const Positioned(
                  top: 14,
                  left: 14,
                  child: _Badge(label: 'Nouveau'),
                ),
              Positioned(
                top: 52,
                left: 14,
                child: _Badge(label: widget.stockLabel),
              ),
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.imageUrls.length, (index) {
                    final selected = index == widget.currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
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
    );
  }
}

class _GalleryArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

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

class _ProductNetworkImage extends StatelessWidget {
  final String url;

  const _ProductNetworkImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final clean = url.trim();
    if (clean.isEmpty) {
      return _placeholder();
    }

    final encoded = Uri.encodeFull(clean);
    final candidates = <String>[encoded];

    if (encoded.toLowerCase().contains('.jpgg')) {
      candidates.add(
        encoded.replaceFirst(RegExp(r'\.jpgg(?=\?|$)', caseSensitive: false), '.jpg'),
      );
    }

    return _TryNetworkImage(candidates: candidates);
  }

  Widget _placeholder() {
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
}

class _TryNetworkImage extends StatefulWidget {
  final List<String> candidates;

  const _TryNetworkImage({required this.candidates});

  @override
  State<_TryNetworkImage> createState() => _TryNetworkImageState();
}

class _TryNetworkImageState extends State<_TryNetworkImage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.candidates[_currentIndex],
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xFFD9C8B8),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      },
      errorBuilder: (_, __, ___) {
        if (_currentIndex < widget.candidates.length - 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _currentIndex += 1;
            });
          });
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

        return Container(
          color: const Color(0xFFD9C8B8),
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            size: 52,
            color: Colors.white70,
          ),
        );
      },
    );
  }
}