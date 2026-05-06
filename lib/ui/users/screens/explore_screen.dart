import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../../../models/listing.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB11A23), // UM Maroon
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/LOGO.png', width: 32, height: 32, errorBuilder: (c,e,s) => const Icon(Icons.school, color: Colors.white)),
            const SizedBox(width: 8),
            const Text('Explore', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.tune, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search all listings...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          
          // Categories
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                CategoryChip(label: 'All', isSelected: true),
                CategoryChip(label: 'Books & Notes'),
                CategoryChip(label: 'Clothing'),
                CategoryChip(label: 'Electronics'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Results Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('listings')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.hasData 
                        ? snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return data['status'] == 'active';
                          }).length
                        : 0;
                    return Text('$count listings found', style: TextStyle(color: Colors.grey.shade600));
                  },
                ),
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFB11A23)),
                    SizedBox(width: 4),
                    Text('UM Campus', style: TextStyle(color: Color(0xFFB11A23), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Grid - FETCHED FROM FIRESTORE (only active/approved)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('listings')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allDocs = snapshot.hasData ? snapshot.data!.docs : [];
                final docs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == 'active';
                }).toList();

                if (snapshot.hasError || docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No Active Listing', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Be the first to post!', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final listing = Listing.fromFirestore(docs[index]);
                    final sellerDisplay = listing.sellerName.isNotEmpty ? listing.sellerName : 'Unknown';
                    final sellerInitial = sellerDisplay.isNotEmpty ? sellerDisplay[0].toUpperCase() : '?';
                    
                    return ProductCard(
                      category: listing.category,
                      title: listing.title,
                      price: '₱${listing.price.toStringAsFixed(0)}',
                      isNegotiable: false,
                      sellerInitials: sellerInitial,
                      sellerName: sellerDisplay,
                      rating: '5.0',
                      time: _timeAgo(listing.createdAt),
                      imageFallbackColor: Colors.grey.shade300,
                      images: listing.images,
                      listingId: listing.id,
                      sellerId: listing.sellerId,
                      description: listing.description,
                      condition: listing.condition,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
