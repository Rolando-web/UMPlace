import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final String listingId;
  final String listingTitle;
  final double amount;
  final double commission;
  final String status; // 'pending', 'paid', 'released', 'refunded'
  final String paymentMethod; // 'gcash', 'maya'
  final String? paymongoPaymentId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.listingId,
    required this.listingTitle,
    required this.amount,
    required this.commission,
    required this.status,
    required this.paymentMethod,
    this.paymongoPaymentId,
    required this.createdAt,
    this.updatedAt,
  });

  double get sellerReceives => amount - commission;

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      buyerId: data['buyerId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      listingId: data['listingId'] ?? '',
      listingTitle: data['listingTitle'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      commission: (data['commission'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? '',
      paymongoPaymentId: data['paymongoPaymentId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'amount': amount,
      'commission': commission,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymongoPaymentId': paymongoPaymentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}
