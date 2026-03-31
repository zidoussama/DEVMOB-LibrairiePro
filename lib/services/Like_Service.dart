import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/LikeModel.dart';

class LikeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _likes =>
      _db.collection('likes');

  String _docId(String userId, String productId) => '${userId}_$productId';

  // Add like
  Future<void> likeProduct(LikeModel like) async {
    await _likes.doc(_docId(like.userId, like.productId)).set(like.toMap());
  }

  // Remove like
  Future<void> unlikeProduct(String userId, String productId) async {
    await _likes.doc(_docId(userId, productId)).delete();
  }

  // Check if user liked the product
  Future<bool> isProductLiked(String userId, String productId) async {
    final doc = await _likes.doc(_docId(userId, productId)).get();
    return doc.exists;
  }

  // Get likes count
  Future<int> getProductLikesCount(String productId) async {
    final query = await _likes.where('productId', isEqualTo: productId).get();
    return query.docs.length;
  }

  Future<void> toggleLike({
    required String userId,
    required String productId,
    required bool currentlyLiked,
  }) async {
    if (currentlyLiked) {
      await unlikeProduct(userId, productId);
      return;
    }

    await likeProduct(
      LikeModel(
        userId: userId,
        productId: productId,
        createdAt: DateTime.now(),
      ),
    );
  }
}
