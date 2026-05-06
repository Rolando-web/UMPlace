import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_listing_screen.dart';
import '../widgets/my_listings_widgets.dart';
import '../../../models/listing.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String _selectedStatus = 'All';

  Future<void> _deleteListing(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('listings').doc(id).delete().timeout(const Duration(seconds: 15));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB11A23), // UM Maroon
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Listings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateListingScreen()));
              },
              icon: const Icon(Icons.add, color: Colors.black, size: 16),
              label: const Text('New', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700), // Yellow
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
      body: user == null
        ? const Center(child: Text('Please log in first'))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('listings')
                .where('sellerId', isEqualTo: user!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final allDocs = snapshot.hasData ? snapshot.data!.docs : [];
              final activeCount = allDocs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'active').length;
              final pendingCount = allDocs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'pending').length;
              final rejectedCount = allDocs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'rejected').length;

              return Column(
                children: [
                  // Stats Row
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(child: ListingStatBox(icon: Icons.inventory_2_outlined, label: 'Active', value: '$activeCount', bgColor: Colors.blue.shade50)),
                        const SizedBox(width: 8),
                        Expanded(child: ListingStatBox(icon: Icons.pending_outlined, label: 'Pending', value: '$pendingCount', bgColor: Colors.orange.shade50)),
                        const SizedBox(width: 8),
                        Expanded(child: ListingStatBox(icon: Icons.cancel_outlined, label: 'Rejected', value: '$rejectedCount', bgColor: Colors.red.shade50)),
                      ],
                    ),
                  ),
                  
                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFilterTab('All', allDocs.length),
                        _buildFilterTab('Pending', pendingCount),
                        _buildFilterTab('Active', activeCount),
                        _buildFilterTab('Rejected', rejectedCount),
                      ],
                    ),
                  ),
                  
                  // List
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final filteredDocs = _selectedStatus == 'All' 
                            ? allDocs 
                            : allDocs.where((d) => (d.data() as Map<String, dynamic>)['status'] == _selectedStatus.toLowerCase()).toList();

                        if (snapshot.hasError || filteredDocs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text(_selectedStatus == 'All' ? 'No listings yet' : 'No $_selectedStatus listings', style: TextStyle(color: Colors.grey.shade500)),
                                if (_selectedStatus == 'All') ...[
                                  const SizedBox(height: 4),
                                  Text('Tap + New to create your first listing!', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                                ],
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredDocs.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final listing = Listing.fromFirestore(filteredDocs[index]);

                            return ListingCard(
                              title: listing.title,
                              price: '₱${listing.price.toStringAsFixed(2)}',
                              views: listing.views.toString(),
                              likes: listing.likes.toString(),
                              offers: '${listing.offers} offers',
                              status: listing.status,
                              imageUrl: listing.images.isNotEmpty ? listing.images[0] : null,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateListingScreen(listing: listing),
                                  ),
                                );
                              },
                              onDelete: () => _deleteListing(listing.id),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildFilterTab(String status, int count) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: ListingTab(
        label: '$status ($count)',
        isSelected: isSelected,
      ),
    );
  }
}
