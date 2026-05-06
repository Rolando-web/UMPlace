import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_listing_screen.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../../../models/listing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            const Text('UMPlace', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
                    hintText: 'Search listings...',
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
            
            const SizedBox(height: 24),
            
            // New Listings Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('New Listings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('See all', style: TextStyle(color: const Color(0xFFB11A23), fontSize: 14)),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // New Listings Grid - FETCHED FROM FIRESTORE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('listings')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  // Filter only active (admin-approved) listings
                  final allDocs = snapshot.hasData ? snapshot.data!.docs : [];
                  final docs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['status'] == 'active';
                  }).toList();

                  if (snapshot.hasError || docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('No Active Listing', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Be the first to post!', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
            
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateListingScreen()));
        },
        backgroundColor: const Color(0xFFFFD700), // Yellow
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }

}
