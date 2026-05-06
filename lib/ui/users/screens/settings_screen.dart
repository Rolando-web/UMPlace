import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'help_support_screen.dart';
import 'my_listings_screen.dart';
import '../widgets/settings_widgets.dart';
import '../../../services/auth_service.dart';
import '../../screens/auth_gate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB11A23), // UM Maroon
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFB11A23),
                  child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(email, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          const Text('4.8', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(' (24 reviews)', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Stats Row
          Row(
            children: [
              Expanded(child: SettingsStatBox(value: '12', label: 'Sold', bgColor: Colors.blue.shade50, textColor: Colors.blue.shade700)),
              const SizedBox(width: 8),
              Expanded(child: SettingsStatBox(value: '8', label: 'Bought', bgColor: Colors.green.shade50, textColor: Colors.green.shade700)),
              const SizedBox(width: 8),
              Expanded(child: SettingsStatBox(value: '24', label: 'Reviews', bgColor: Colors.yellow.shade50, textColor: Colors.orange.shade700)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          SettingsMenuTile(icon: Icons.edit_outlined, label: 'Edit Profile', iconBgColor: Colors.red.shade50, iconColor: const Color(0xFFB11A23)),
          const SizedBox(height: 12),
          SettingsMenuTile(
            icon: Icons.inventory_2_outlined, 
            label: 'My Listings', 
            iconBgColor: Colors.blue.shade50, 
            iconColor: Colors.blue.shade700,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyListingsScreen()));
            },
          ),
          const SizedBox(height: 12),
          SettingsMenuTile(icon: Icons.history_outlined, label: 'Transactions', iconBgColor: Colors.orange.shade50, iconColor: Colors.orange.shade700),
          const SizedBox(height: 12),
          SettingsMenuTile(icon: Icons.bookmark_border, label: 'Saved Items', iconBgColor: Colors.green.shade50, iconColor: Colors.green.shade700),
          const SizedBox(height: 12),
          SettingsMenuTile(icon: Icons.star_border, label: 'Reviews', iconBgColor: Colors.yellow.shade50, iconColor: Colors.orange.shade700),
          const SizedBox(height: 12),
          SettingsMenuTile(icon: Icons.settings_outlined, label: 'Settings', iconBgColor: Colors.grey.shade100, iconColor: Colors.grey.shade700),
          
          const SizedBox(height: 24),
          
          // Account Section
          const Text('Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          SettingsAccountTile(icon: Icons.notifications_none, label: 'Notifications'),
          const SizedBox(height: 8),
          SettingsAccountTile(icon: Icons.lock_outline, label: 'Privacy & Security'),
          const SizedBox(height: 8),
          SettingsAccountTile(icon: Icons.shield_outlined, label: 'Trust & Safety'),
          const SizedBox(height: 8),
          SettingsAccountTile(icon: Icons.help_outline, label: 'Help & Support', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
          }),
          
          const SizedBox(height: 24),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
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
              label: const Text('Logout', style: TextStyle(color: Color(0xFFB11A23))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
