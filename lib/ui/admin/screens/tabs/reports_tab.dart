import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_widgets.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Chips
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Pending'),
                _buildFilterChip('Under Review'),
                _buildFilterChip('Resolved'),
              ],
            ),
          ),
        ),
        
        // Reports List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reports')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allDocs = snapshot.hasData ? snapshot.data!.docs : [];
              final docs = _selectedFilter == 'All' 
                  ? allDocs 
                  : allDocs.where((doc) => (doc.data() as Map<String, dynamic>)['status'] == _selectedFilter.toLowerCase()).toList();

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.report_outlined, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No reports found', style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return AdminReportCard(
                    severity: data['severity'] ?? 'MEDIUM',
                    category: data['category'] ?? 'General',
                    time: _timeAgo((data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()),
                    title: data['title'] ?? 'No Title',
                    seller: data['sellerName'] ?? 'Unknown',
                    reporter: data['reporterName'] ?? 'Anonymous',
                    description: data['description'] ?? '',
                    status: data['status'] ?? 'pending',
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AdminFilterChip(label: label, isSelected: isSelected),
    );
  }
}
