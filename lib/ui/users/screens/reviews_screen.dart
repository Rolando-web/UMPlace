import 'package:flutter/material.dart';
import '../../../models/review.dart';
import '../../../services/auth_service.dart';
import '../../../services/review_service.dart';
import 'package:intl/intl.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService().currentUserId;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB11A23),
        title: const Text('My Reviews', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<ReviewModel>>(
        stream: ReviewService.getUserReviews(currentUserId ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No reviews yet', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final review = snapshot.data![index];
              return _buildReviewCard(review);
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.reviewerName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(review.createdAt),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              'Item: ${review.listingTitle}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
