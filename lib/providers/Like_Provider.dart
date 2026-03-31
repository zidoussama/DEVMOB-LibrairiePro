import 'package:flutter/material.dart';
import '../controllers/like_controller.dart';

class LikeProvider with ChangeNotifier {
  final LikeController _controller;

  LikeProvider({LikeController? controller})
    : _controller = controller ?? LikeController();

  final Set<String> _likedProductIds = <String>{};
  final Map<String, int> _likesCountByProduct = <String, int>{};
  final Set<String> _syncedProductIds = <String>{};
  final Set<String> _syncInProgress = <String>{};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isProductLiked(String productId) => _likedProductIds.contains(productId);

  int likesCountForProduct(String productId) =>
      _likesCountByProduct[productId] ?? 0;

  Future<void> syncForProducts({
    required String userId,
    required List<String> productIds,
  }) async {
    final toSync = productIds
        .where(
          (id) =>
              id.isNotEmpty &&
              !_syncedProductIds.contains(id) &&
              !_syncInProgress.contains(id),
        )
        .toList();

    if (toSync.isEmpty) return;

    _isLoading = true;
    _error = null;
    _syncInProgress.addAll(toSync);
    notifyListeners();

    try {
      await Future.wait(
        toSync.map((productId) async {
          final liked = await _controller.isProductLiked(
            userId: userId,
            productId: productId,
          );
          final count = await _controller.getProductLikesCount(productId);

          if (liked) {
            _likedProductIds.add(productId);
          } else {
            _likedProductIds.remove(productId);
          }
          _likesCountByProduct[productId] = count;
          _syncedProductIds.add(productId);
        }),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _syncInProgress.removeAll(toSync);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLikeForProduct({
    required String userId,
    required String productId,
  }) async {
    final currentlyLiked = _likedProductIds.contains(productId);

    if (currentlyLiked) {
      _likedProductIds.remove(productId);
      _likesCountByProduct[productId] =
          (_likesCountByProduct[productId] ?? 0) > 0
          ? (_likesCountByProduct[productId] ?? 0) - 1
          : 0;
    } else {
      _likedProductIds.add(productId);
      _likesCountByProduct[productId] =
          (_likesCountByProduct[productId] ?? 0) + 1;
    }
    notifyListeners();

    try {
      await _controller.toggleLike(
        userId: userId,
        productId: productId,
        currentlyLiked: currentlyLiked,
      );
      _syncedProductIds.add(productId);
    } catch (e) {
      // rollback optimistic update on failure
      if (currentlyLiked) {
        _likedProductIds.add(productId);
        _likesCountByProduct[productId] =
            (_likesCountByProduct[productId] ?? 0) + 1;
      } else {
        _likedProductIds.remove(productId);
        _likesCountByProduct[productId] =
            (_likesCountByProduct[productId] ?? 0) > 0
            ? (_likesCountByProduct[productId] ?? 0) - 1
            : 0;
      }
      _error = e.toString();
      notifyListeners();
    }
  }
}
