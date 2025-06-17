import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String vetId;
  final String farmerId;
  final String comment;
  final double rating;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.vetId,
    required this.farmerId,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> data, String id) {
    return ReviewModel(
      id: id,
      vetId: data['vetId'] ?? '',
      farmerId: data['farmerId'] ?? '',
      comment: data['comment'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vetId': vetId,
      'farmerId': farmerId,
      'comment': comment,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
