import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/transaction.dart';
import '../../../services/auth_service.dart';
import '../../../services/paymongo_service.dart';
import '../widgets/transactions_widgets.dart';
import '../widgets/review_widgets.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService().currentUserId;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFB11A23),
          title: const Text('My Transactions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Purchases'),
              Tab(text: 'Sales'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTransactionList(currentUserId, isBuyer: true),
            _buildTransactionList(currentUserId, isBuyer: false),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(String? userId, {required bool isBuyer}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where(isBuyer ? 'buyerId' : 'sellerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('No transactions yet', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final tx = TransactionModel.fromFirestore(snapshot.data!.docs[index]);
            return TransactionCard(
              tx: tx, 
              isBuyer: isBuyer,
              onConfirmReceipt: () => _confirmReceipt(context, tx),
            );
          },
        );
      },
    );
  }

  void _confirmReceipt(BuildContext context, TransactionModel tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Receipt?'),
        content: const Text(
          'By confirming, you agree that you have received the item and it is in the described condition. This will release the funds to the seller and cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await PaymongoService.releaseFunds(tx.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funds released successfully!'), backgroundColor: Colors.green),
                );
                // Trigger Review Modal
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => ReviewModal(tx: tx),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Confirm & Release'),
          ),
        ],
      ),
    );
  }
}
