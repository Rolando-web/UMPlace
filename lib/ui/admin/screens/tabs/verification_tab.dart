import 'package:flutter/material.dart';

class VerificationTab extends StatelessWidget {
  const VerificationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No Verification Requests', style: TextStyle(color: Colors.grey.shade500, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Student verification requests will appear here.', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
        ],
      ),
    );
  }
}
