import 'package:cloud_firestore/cloud_firestore.dart';

class LikeModel {
  final String userId;
  final String productId;
  final DateTime createdAt;

  LikeModel({
    required this.userId,
    required this.productId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'productId': productId, 'createdAt': createdAt};
  }

  factory LikeModel.fromMap(Map<String, dynamic> map) {
    final dynamic rawCreatedAt = map['createdAt'];

    return LikeModel(
      userId: (map['userId'] ?? '').toString(),
      productId: (map['productId'] ?? map['postId'] ?? '').toString(),
      createdAt: rawCreatedAt is Timestamp
          ? rawCreatedAt.toDate()
          : DateTime.tryParse(rawCreatedAt?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
