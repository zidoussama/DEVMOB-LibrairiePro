import '../services/Like_Service.dart';

class LikeController {
  final LikeService _service;

  LikeController({LikeService? service}) : _service = service ?? LikeService();

  Future<bool> isProductLiked({
    required String userId,
    required String productId,
  }) {
    return _service.isProductLiked(userId, productId);
  }

  Future<int> getProductLikesCount(String productId) {
    return _service.getProductLikesCount(productId);
  }

  Future<void> toggleLike({
    required String userId,
    required String productId,
    required bool currentlyLiked,
  }) {
    return _service.toggleLike(
      userId: userId,
      productId: productId,
      currentlyLiked: currentlyLiked,
    );
  }
}
