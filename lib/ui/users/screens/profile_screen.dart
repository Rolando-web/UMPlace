import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_listings_screen.dart';
import 'settings_screen.dart';
import '../widgets/profile_widgets.dart';
import '../../../services/auth_service.dart';
import '../../screens/auth_gate.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    
    String name = 'User';
    String initial = 'U';
    
    if (email.isNotEmpty) {
      final parts = email.split('@');
      if (parts.isNotEmpty) {
        name = parts[0].replaceAll(RegExp(r'\.[0-9]+$'), '');
        if (name.isNotEmpty) {
          initial = name[0].toUpperCase();
        }
      }
    }

    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      name = user.displayName!;
      initial = name[0].toUpperCase();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB11A23), // UM Maroon
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
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(email, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            
            // Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.black),
                      SizedBox(width: 4),
                      Text('5', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_outlined, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Verified', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ProfileStatColumn(value: '12', label: 'Sold'),
                ProfileStatColumn(value: '5', label: 'Bought'),
                ProfileStatColumn(value: '8', label: 'Reviews'),
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
                  ProfileMenuCard(icon: Icons.history_outlined, label: 'Transactions', onTap: () {}),
                  ProfileMenuCard(icon: Icons.bookmark_border, label: 'Saved Items', onTap: () {}),
                  ProfileMenuCard(icon: Icons.chat_bubble_outline, label: 'Reviews', onTap: () {}),
                  ProfileMenuCard(icon: Icons.settings_outlined, label: 'Settings', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                  }),
                ],                   
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Trust Score Breakdown
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
                    const Text('Trust Score Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TrustProgress(label: 'Response Rate', percentage: '98%', value: 0.98),
                    const SizedBox(height: 12),
                    TrustProgress(label: 'Completion Rate', percentage: '95%', value: 0.95),
                    const SizedBox(height: 12),
                    TrustProgress(label: 'Positive Reviews', percentage: '92%', value: 0.92),
                    const SizedBox(height: 16),
                    Text('How to improve →', style: TextStyle(color: const Color(0xFFB11A23), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Help & Support
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.help_outline, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('FAQs, guidelines, and contact support', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.grey.shade400, size: 20),
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
}
