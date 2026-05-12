import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/listing.dart';
import '../../../../bloc/admin/manage_listings_bloc.dart';

class ManageListingsTab extends StatelessWidget {
  const ManageListingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManageListingsBloc(),
      child: const _ManageListingsTabView(),
    );
  }
}

class _ManageListingsTabView extends StatefulWidget {
  const _ManageListingsTabView();

  @override
  State<_ManageListingsTabView> createState() => _ManageListingsTabViewState();
}

class _ManageListingsTabViewState extends State<_ManageListingsTabView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRejectionDialog(BuildContext context, String listingId, ManageListingsBloc bloc) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Listing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejection:', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Inappropriate images, price too high, etc.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a reason')));
                return;
              }
              bloc.add(UpdateListingStatus(listingId, 'rejected', reason: controller.text.trim()));
              Navigator.pop(context); // Close dialog
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showDetailModal(Listing listing) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<ManageListingsBloc>(),
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 500,
              constraints: const BoxConstraints(maxHeight: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: listing.status == 'pending'
                          ? Colors.orange.shade50
                          : listing.status == 'active'
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          listing.status == 'pending' ? Icons.pending 
                            : listing.status == 'active' ? Icons.check_circle 
                            : Icons.cancel,
                          color: listing.status == 'pending' ? Colors.orange 
                            : listing.status == 'active' ? Colors.green 
                            : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Review Listing — ${listing.status.toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                  ),
                  // Body
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Display
                          if (listing.images.isNotEmpty)
                            SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: listing.images.length,
                                itemBuilder: (c, i) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: i < listing.images.length - 1 ? 8 : 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        listing.images[i],
                                        width: 200,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          width: 200, height: 180,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, size: 40, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text('No images uploaded', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Title & Price
                          Text(listing.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('₱${listing.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFB11A23))),
                          const SizedBox(height: 16),

                          // Info Grid
                          _infoRow('Category', listing.category),
                          _infoRow('Condition', listing.condition),
                          _infoRow('Seller', listing.sellerName.isNotEmpty ? listing.sellerName : 'Unknown'),
                          _infoRow('Email', listing.sellerEmail.isNotEmpty ? listing.sellerEmail : 'N/A'),
                          _infoRow('Posted', '${listing.createdAt.day}/${listing.createdAt.month}/${listing.createdAt.year}'),
                          _infoRow('Status', listing.status.toUpperCase()),
                          if (listing.rejectionReason != null) 
                            _infoRow('Reason', listing.rejectionReason!, isRed: true),
                          
                          const SizedBox(height: 16),
                          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              listing.description.isNotEmpty ? listing.description : 'No description provided.',
                              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Footer Actions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: BlocBuilder<ManageListingsBloc, ManageListingsState>(
                      builder: (blocContext, state) {
                        final isLoading = state is ManageListingsLoading;
                        return Row(
                          children: [
                            if (listing.status == 'pending' || listing.status == 'rejected')
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isLoading ? null : () {
                                    blocContext.read<ManageListingsBloc>().add(UpdateListingStatus(listing.id, 'active'));
                                    Navigator.pop(dialogContext);
                                  },
                                  icon: const Icon(Icons.check_circle, size: 18),
                                  label: const Text('Approve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            if (listing.status == 'pending') const SizedBox(width: 8),
                            if (listing.status == 'pending' || listing.status == 'active')
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isLoading ? null : () {
                                    _showRejectionDialog(dialogContext, listing.id, blocContext.read<ManageListingsBloc>());
                                    Navigator.pop(dialogContext); // Close the detail modal first
                                  },
                                  icon: const Icon(Icons.cancel, size: 18),
                                  label: const Text('Reject'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            if (listing.status == 'rejected') const SizedBox(width: 8),
                            if (listing.status == 'rejected')
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: isLoading ? null : () {
                                    blocContext.read<ManageListingsBloc>().add(DeleteListing(listing.id));
                                    Navigator.pop(dialogContext);
                                  },
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: isRed ? Colors.red : Colors.grey.shade600, fontSize: 13, fontWeight: isRed ? FontWeight.bold : FontWeight.normal)),
          ),
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: isRed ? Colors.red : Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildListingsList(String statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('listings').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = snapshot.hasData ? snapshot.data!.docs : [];
        final docs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == statusFilter;
        }).toList();

        if (snapshot.hasError || docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  statusFilter == 'pending' ? 'No pending listings to review'
                  : statusFilter == 'active' ? 'No active listings'
                  : 'No rejected listings',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final listing = Listing.fromFirestore(docs[index]);
            return GestureDetector(
              onTap: () => _showDetailModal(listing),
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image thumbnail
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: listing.images.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      listing.images[0],
                                      width: 60, height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  )
                                : const Icon(Icons.image, color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(listing.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('₱${listing.price.toStringAsFixed(2)} • ${listing.category}', style: TextStyle(color: Colors.grey.shade700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Seller: ${listing.sellerName.isNotEmpty ? listing.sellerName : 'Unknown'}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Status + View
                          SizedBox(
                            width: 90,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusFilter == 'active'
                                        ? Colors.green.shade50
                                        : statusFilter == 'pending'
                                            ? Colors.orange.shade50
                                            : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    listing.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: statusFilter == 'active'
                                          ? Colors.green.shade700
                                          : statusFilter == 'pending'
                                              ? Colors.orange.shade700
                                              : Colors.red.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('View Details →', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Quick Actions for pending
                      if (statusFilter == 'pending') const SizedBox(height: 12),
                      if (statusFilter == 'pending')
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => context.read<ManageListingsBloc>().add(UpdateListingStatus(listing.id, 'active')),
                                icon: const Icon(Icons.check_circle, size: 18),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showRejectionDialog(context, listing.id, context.read<ManageListingsBloc>()),
                                icon: const Icon(Icons.cancel, size: 18),
                                label: const Text('Reject'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageListingsBloc, ManageListingsState>(
      listener: (context, state) {
        if (state is ManageListingsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is ManageListingsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
        }
      },
      child: Column(
        children: [
          // Sub-tabs for Pending / Active / Rejected
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFFB11A23),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xFFB11A23),
              tabs: [
                Tab(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('listings').snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.hasData
                          ? snapshot.data!.docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'pending').length
                          : 0;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Pending'),
                          if (count > 0) const SizedBox(width: 6),
                          if (count > 0)
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                              child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const Tab(text: 'Active'),
                const Tab(text: 'Rejected'),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListingsList('pending'),
                _buildListingsList('active'),
                _buildListingsList('rejected'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
