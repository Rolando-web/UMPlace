import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tabs/overview_tab.dart';
import 'tabs/reports_tab.dart';
import 'tabs/verification_tab.dart';
import 'tabs/transactions_tab.dart';
import 'tabs/manage_listings_tab.dart';
import 'tabs/revenue_tab.dart';
import '../../../services/auth_service.dart';
import '../../screens/auth_gate.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _titles = ['Admin Dashboard', 'Admin Report', 'Admin Verification', 'Admin Transactions', 'Manage Listings', 'Admin Revenue'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildDesktopLayout(String userName) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: const Color(0xFFB11A23),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Image.asset('assets/images/logo.png', height: 80),
                const SizedBox(height: 16),
                const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(userName, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 32),
                _buildSidebarItem(0, Icons.dashboard, 'Overview'),
                _buildSidebarItem(1, Icons.report, 'Reports'),
                _buildSidebarItem(2, Icons.verified_user, 'Verification'),
                _buildSidebarItem(3, Icons.list_alt, 'Transactions'),
                _buildSidebarItem(4, Icons.inventory_2, 'Manage Listings'),
                _buildSidebarItem(5, Icons.attach_money, 'Revenue'),
                const Spacer(),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text('Logout', style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    await AuthService().signOut();
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthGate()),
                        (route) => false,
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    // Header
                    Container(
                      height: 80,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        children: [
                          Text(_titles[_tabController.index], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_down, color: Color(0xFFB11A23), size: 28),
                        ],
                      ),
                    ),
                    // Tab Content
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(), // Desktop doesn't need swipe
                            children: const [
                              OverviewTab(),
                              ReportsTab(),
                              VerificationTab(),
                              TransactionsTab(),
                              ManageListingsTab(),
                              RevenueTab(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title, {String? badge}) {
    final isSelected = _tabController.index == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? const Color(0xFFB11A23) : Colors.white),
        title: Text(title, style: TextStyle(color: isSelected ? const Color(0xFFB11A23) : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFB11A23) : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(badge, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFFB11A23), fontSize: 10, fontWeight: FontWeight.bold)),
              )
            : null,
        onTap: () {
          _tabController.animateTo(index);
        },
      ),
    );
  }

  Widget _buildMobileLayout(String userName) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB11A23),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo.png'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_titles[_tabController.index], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(userName, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            onSelected: (value) async {
              if (value == 'logout') {
                await AuthService().signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthGate()),
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Color(0xFFB11A23)),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kTextTabBarHeight),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFB11A23),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xFFB11A23),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
              isScrollable: true,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Reports'),
                Tab(text: 'Verification'),
                Tab(text: 'Transactions'),
                Tab(text: 'Listings'),
                Tab(text: 'Revenue'),
              ],  
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OverviewTab(),
          ReportsTab(),
          VerificationTab(),
          TransactionsTab(),
          ManageListingsTab(),
          RevenueTab(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    
    String userName = 'Admin User';
    
    if (email.isNotEmpty) {
      final parts = email.split('@');
      if (parts.isNotEmpty) {
        // Keep the exact prefix e.g. "r.luayon.548815"
        userName = parts[0]; 
      }
    } else if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      userName = user.displayName!;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildDesktopLayout(userName);
        }
        return _buildMobileLayout(userName);
      },
    );
  }
}
