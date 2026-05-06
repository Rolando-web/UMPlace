import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_widgets.dart';

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.hasData ? snapshot.data!.docs : [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('No Transactions', style: TextStyle(color: Colors.grey.shade500, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Transaction records will appear here.', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            
            return AdminTransactionCard(
              statusBadge: (data['status'] ?? 'pending').toUpperCase(),
              itemCategory: data['category'] ?? 'General',
              time: _timeAgo(createdAt),
              title: data['title'] ?? 'Transaction',
              amount: '₱${(data['amount'] ?? 0).toStringAsFixed(2)}',
              fee: '₱${((data['amount'] ?? 0) * 0.10).toStringAsFixed(2)}', // 10% fee
              paymentMethod: data['paymentMethod'] ?? 'GCash',
              bottomBadgeStatus: data['status'] ?? 'pending',
            );
          },
        );
      },
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
