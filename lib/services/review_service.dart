import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> submitReview(ReviewModel review) async {
    await _firestore.collection('reviews').add(review.toMap());
    
    // Also update seller's average rating in their user document
    final targetUserRef = _firestore.collection('users').doc(review.targetUserId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(targetUserRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final double currentRating = (data['averageRating'] ?? 5.0).toDouble();
      final int totalReviews = data['totalReviews'] ?? 0;

      final double newRating = ((currentRating * totalReviews) + review.rating) / (totalReviews + 1);
      
      transaction.update(targetUserRef, {
        'averageRating': newRating,
        'totalReviews': totalReviews + 1,
      });
    });
  }

  static Stream<List<ReviewModel>> getUserReviews(String userId) {
    return _firestore
        .collection('reviews')
        .where('targetUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList());
  }
}
