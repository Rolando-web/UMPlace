import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart';

class PaymongoService {
  static final String _secretKey = dotenv.env['PAYMONGO_SECRET_KEY'] ?? '';
  static final String _baseUrl = 'https://api.paymongo.com/v1';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Basic ${base64Encode(utf8.encode('$_secretKey:'))}',
      };

  /// Creates a Payment Intent
  static Future<Map<String, dynamic>?> createPaymentIntent(double amount, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: _headers,
        body: jsonEncode({
          'data': {
            'attributes': {
              'amount': (amount * 100).toInt(), // Paymongo uses centavos
              'payment_method_allowed': ['gcash', 'paymaya'],
              'currency': 'PHP',
              'description': description,
            }
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['data'];
      } else {
        print('Paymongo Error (Payment Intent): ${response.body}');
        return null;
      }
    } catch (e) {
      print('Paymongo Exception: $e');
      return null;
    }
  }

  /// Creates a Payment Source (for GCash/Maya) - Legacy but simpler for some flows
  /// Most modern integrations use Payment Intents + Payment Methods.
  /// But let's use Payment Source for a direct redirect flow if preferred.
  static Future<Map<String, dynamic>?> createSource(double amount, String type, String successUrl, String cancelUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sources'),
        headers: _headers,
        body: jsonEncode({
          'data': {
            'attributes': {
              'amount': (amount * 100).toInt(),
              'type': type, // 'gcash' or 'paymaya'
              'currency': 'PHP',
              'redirect': {
                'success': successUrl,
                'failed': cancelUrl,
              }
            }
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['data'];
      } else {
        print('Paymongo Error (Source): ${response.body}');
        return null;
      }
    } catch (e) {
      print('Paymongo Exception: $e');
      return null;
    }
  }

  /// Record a transaction in Firestore (Escrow)
  static Future<String> createEscrowTransaction({
    required String buyerId,
    required String sellerId,
    required String listingId,
    required String listingTitle,
    required double amount,
    required String paymentMethod,
  }) async {
    final commission = amount * 0.05; // 5% commission example
    final docRef = FirebaseFirestore.instance.collection('transactions').doc();
    
    final transaction = TransactionModel(
      id: docRef.id,
      buyerId: buyerId,
      sellerId: sellerId,
      listingId: listingId,
      listingTitle: listingTitle,
      amount: amount,
      commission: commission,
      status: 'pending',
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );

    await docRef.set(transaction.toMap());
    return docRef.id;
  }

  /// Update transaction status
  static Future<void> updateTransactionStatus(String transactionId, String status, {String? paymentId}) async {
    final txDoc = await FirebaseFirestore.instance.collection('transactions').doc(transactionId).get();
    final listingId = txDoc.data()?['listingId'];

    await FirebaseFirestore.instance.collection('transactions').doc(transactionId).update({
      'status': status,
      if (paymentId != null) 'paymongoPaymentId': paymentId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Mark product as SOLD once paid
    if (status == 'paid' && listingId != null) {
      await FirebaseFirestore.instance.collection('listings').doc(listingId).update({
        'status': 'sold',
      });
    }
  }

  /// Release funds to seller (Escrow logic)
  static Future<void> releaseFunds(String transactionId) async {
    // In a real system, this would trigger a payout or update a seller's balance
    await updateTransactionStatus(transactionId, 'released');
  }

  /// Generate test payment methods for a user
  static Future<void> generateTestPaymentMethods(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'paymentMethods': {
        'gcash': '09123456789',
        'maya': '09987654321',
      }
    });
  }
}
