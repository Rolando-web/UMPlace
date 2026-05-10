import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';

class VerificationTab extends StatelessWidget {
  const VerificationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('verificationStatus', isEqualTo: 'pending')
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
                Icon(Icons.verified_user_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('No Verification Requests',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Student verification requests will appear here.',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final userData = UserModel.fromFirestore(doc);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFB11A23),
                  child: Text(userData.displayName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                ),
                title: Text(userData.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(userData.email),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Uploaded Student ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (userData.studentIdUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              userData.studentIdUrl!,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey.shade100,
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showConfirmation(context, userData, true),
                                icon: const Icon(Icons.check),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showConfirmation(context, userData, false),
                                icon: const Icon(Icons.close),
                                label: const Text('Reject'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmation(BuildContext context, UserModel user, bool approve) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Approve Verification?' : 'Reject Verification?'),
        content: Text(approve 
          ? 'This will verify ${user.displayName} and add 20 points to their Trust Score.' 
          : 'This will reject the verification request for ${user.displayName}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (approve) {
                await AuthService().approveVerification(user.uid);
              } else {
                await AuthService().rejectVerification(user.uid);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(approve ? 'Verification approved!' : 'Verification rejected.')),
                );
              }
            },
            child: Text(approve ? 'Approve' : 'Reject', style: TextStyle(color: approve ? Colors.green : Colors.red)),
          ),
        ],
      ),
    );
  }
}
