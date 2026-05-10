import 'package:flutter/material.dart';
import '../../../models/transaction.dart';
import '../../../models/review.dart';
import '../../../services/auth_service.dart';
import '../../../services/review_service.dart';

class ReviewModal extends StatefulWidget {
  final TransactionModel tx;

  const ReviewModal({super.key, required this.tx});

  @override
  State<ReviewModal> createState() => _ReviewModalState();
}

class _ReviewModalState extends State<ReviewModal> {
  double _selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate your experience'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('How was your transaction for "${widget.tx.listingTitle}"?', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: _isSubmitting ? null : () => setState(() => _selectedRating = index + 1.0),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              hintText: 'Share your experience with this seller...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Skip'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB11A23), 
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey,
          ),
          child: _isSubmitting 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Submit Review'),
        ),
      ],
    );
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);
    try {
      final user = await AuthService().getUserData();
      if (user == null) return;

      final review = ReviewModel(
        id: '',
        reviewerId: user.uid,
        reviewerName: user.displayName,
        targetUserId: widget.tx.sellerId,
        listingId: widget.tx.listingId,
        listingTitle: widget.tx.listingTitle,
        rating: _selectedRating,
        comment: _commentController.text,
        createdAt: DateTime.now(),
      );

      await ReviewService.submitReview(review);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted! Thank you.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
