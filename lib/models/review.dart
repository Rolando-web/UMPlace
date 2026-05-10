import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String targetUserId; // The person being reviewed (seller)
  final String listingId;
  final String listingTitle;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.targetUserId,
    required this.listingId,
    required this.listingTitle,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'targetUserId': targetUserId,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      reviewerId: data['reviewerId'] ?? '',
      reviewerName: data['reviewerName'] ?? '',
      targetUserId: data['targetUserId'] ?? '',
      listingId: data['listingId'] ?? '',
      listingTitle: data['listingTitle'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
