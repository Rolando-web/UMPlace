import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int trustScore;
  final String verificationStatus; // 'none', 'pending', 'verified', 'rejected'
  final bool hasCompletedOnboarding;
  final String? studentIdUrl;
  final Map<String, String>? paymentMethods; // e.g., {'gcash': '09123456789', 'maya': '09123456789'}
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.trustScore = 80,
    this.verificationStatus = 'none',
    this.hasCompletedOnboarding = false,
    this.studentIdUrl,
    this.paymentMethods,
    this.createdAt,
  });

  bool get isVerified => verificationStatus == 'verified';

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      trustScore: data['trustScore'] ?? 80,
      verificationStatus: data['verificationStatus'] ?? 'none',
      hasCompletedOnboarding: data['hasCompletedOnboarding'] ?? false,
      studentIdUrl: data['studentIdUrl'],
      paymentMethods: data['paymentMethods'] != null 
          ? Map<String, String>.from(data['paymentMethods']) 
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'trustScore': trustScore,
      'verificationStatus': verificationStatus,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'studentIdUrl': studentIdUrl,
      'paymentMethods': paymentMethods,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  int get listingLimit {
    if (trustScore < 60) return 0; // No longer post a list
    if (trustScore < 80) return 1;
    if (trustScore < 90) return 2;
    return 3;
  }
}
