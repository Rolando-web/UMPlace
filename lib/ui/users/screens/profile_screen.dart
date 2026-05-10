import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'my_listings_screen.dart';
import 'settings_screen.dart';
import 'transactions_screen.dart';
import 'reviews_screen.dart';
import '../widgets/profile_widgets.dart';
import '../../../services/auth_service.dart';
import '../../../services/cloudinary_service.dart';
import '../../../models/user_model.dart';
import '../../../services/paymongo_service.dart';
import '../../screens/auth_gate.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;

  Future<void> _handleIdVerification() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final String imageUrl = await CloudinaryService.uploadImage(image);
      await AuthService().verifyId(imageUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID Verification submitted successfully! Trust score updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: AuthService().userModelStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final userData = snapshot.data;
        if (userData == null) {
          return const Scaffold(body: Center(child: Text('User not found')));
        }

        final initial = userData.displayName.isNotEmpty ? userData.displayName[0].toUpperCase() : 'U';

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFB11A23),
            elevation: 0,
            title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Profile Header
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFFB11A23),
                      child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(userData.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(userData.email, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 12),
                
                // Trust Score Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield, size: 16, color: Colors.black87),
                          const SizedBox(width: 6),
                          Text(
                            'Trust Score: ${userData.trustScore}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    if (userData.isVerified) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(16)),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Verified Student', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 24),

                if (userData.verificationStatus == 'none' || userData.verificationStatus == 'rejected')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: userData.verificationStatus == 'rejected' ? Colors.red.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: userData.verificationStatus == 'rejected' ? Colors.red.shade200 : Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                userData.verificationStatus == 'rejected' ? Icons.error_outline : Icons.info_outline, 
                                color: userData.verificationStatus == 'rejected' ? Colors.red : Colors.blue
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  userData.verificationStatus == 'rejected' 
                                    ? 'Your previous ID was rejected. Please upload a clear, latest Student ID.'
                                    : 'Get +20 Trust Score by verifying your Student ID!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    color: userData.verificationStatus == 'rejected' ? Colors.red : Colors.blue
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isUploading ? null : _handleIdVerification,
                              icon: _isUploading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.badge_outlined),
                              label: Text(_isUploading ? 'Uploading...' : 'Verify Student ID'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: userData.verificationStatus == 'rejected' ? Colors.red : Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (userData.verificationStatus == 'pending')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.hourglass_empty, color: Colors.orange),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Verification Pending. An admin will review your Student ID shortly.',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ProfileStatColumn(value: userData.listingLimit.toString(), label: 'Limit'),
                    ProfileStatColumn(value: userData.trustScore.toString(), label: 'Score'),
                    ProfileStatColumn(value: userData.isVerified ? 'Yes' : 'No', label: 'Verified'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Grid Menu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      ProfileMenuCard(icon: Icons.edit_outlined, label: 'Edit Profile', onTap: () {}),
                      ProfileMenuCard(icon: Icons.inventory_2_outlined, label: 'My Listings', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyListingsScreen()));
                      }),
                      ProfileMenuCard(icon: Icons.history_outlined, label: 'Transactions', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionsScreen()));
                      }),
                      ProfileMenuCard(icon: Icons.bookmark_border, label: 'Saved Items', onTap: () {}),
                      ProfileMenuCard(icon: Icons.chat_bubble_outline, label: 'Reviews', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewsScreen()));
                      }),
                      ProfileMenuCard(icon: Icons.settings_outlined, label: 'Settings', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                      }),
                    ],                   
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Payment Methods Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Escrow Payout Methods', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Icon(Icons.account_balance_wallet_outlined, size: 20, color: Color(0xFFB11A23)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Where you receive your earnings', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        const SizedBox(height: 16),
                        if (userData.paymentMethods == null || userData.paymentMethods!.isEmpty)
                          Column(
                            children: [
                              Center(child: Text('No payout methods linked.', style: TextStyle(color: Colors.grey.shade600, fontSize: 14))),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => PaymongoService.generateTestPaymentMethods(userData.uid),
                                  icon: const Icon(Icons.auto_awesome, size: 18),
                                  label: const Text('Generate Test Accounts'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFB11A23),
                                    side: const BorderSide(color: Color(0xFFB11A23)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildPaymentMethodItem('GCash', userData.paymentMethods!['gcash'] ?? 'Not set', Colors.blue),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(height: 1),
                          ),
                          _buildPaymentMethodItem('Maya', userData.paymentMethods!['maya'] ?? 'Not set', Colors.green),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                
                // Trust Score Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('System Guidelines', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildGuideline('Default Score', '80 points'),
                        _buildGuideline('Verification Bonus', '+20 points'),
                        _buildGuideline('Score 90+', '3 listings max'),
                        _buildGuideline('Score 80-89', '2 listings max'),
                        _buildGuideline('Score 60-79', '1 listing max'),
                        _buildGuideline('Score < 60', 'Restricted posting'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Log out
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        await AuthService().signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const AuthGate()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, color: Color(0xFFB11A23)),
                      label: const Text('Log out', style: TextStyle(color: Color(0xFFB11A23), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildPaymentMethodItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.phone_android, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(value, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
        const Spacer(),
        const Icon(Icons.check_circle, color: Colors.green, size: 16),
      ],
    );
  }

  Widget _buildGuideline(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
