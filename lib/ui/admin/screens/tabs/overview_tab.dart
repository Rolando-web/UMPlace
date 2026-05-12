import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/admin_widgets.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('listings').snapshots(),
      builder: (context, snapshot) {
        final allDocs = snapshot.hasData ? snapshot.data!.docs : <QueryDocumentSnapshot<Object?>>[];
        final activeCount = allDocs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'active').length;
        final pendingCount = allDocs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'pending').length;
        
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('reports').snapshots(),
          builder: (context, reportsSnapshot) {
            final reportsCount = reportsSnapshot.hasData ? reportsSnapshot.data!.docs.length : 0;
            
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('transactions').snapshots(),
              builder: (context, transSnapshot) {
                final transactionsCount = transSnapshot.hasData ? transSnapshot.data!.docs.length : 0;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 800;

                    final card1 = AdminStatCard(
                      icon: Icons.inventory_2_outlined,
                      value: '$activeCount',
                      label: 'Total Active Listings',
                      iconColor: const Color(0xFFB11A23),
                      bgColor: Colors.white,
                    );
                    final card2 = AdminStatCard(
                      icon: Icons.shield_outlined,
                      value: '$pendingCount',
                      label: 'Pending Listings',
                      iconColor: Colors.amber.shade600,
                      bgColor: Colors.white,
                    );
                    final card3 = AdminStatCard(
                      icon: Icons.report_gmailerrorred_outlined,
                      value: '$reportsCount',
                      label: 'Open Reports',
                      iconColor: Colors.red.shade400,
                      bgColor: Colors.white,
                    );
                    final card4 = AdminStatCard(
                      icon: Icons.list_alt,
                      value: '$transactionsCount',
                      label: "Today's Transactions",
                      iconColor: Colors.green.shade600,
                      bgColor: Colors.white,
                    );

                    return ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        if (isDesktop)
                          Row(
                            children: [
                              Expanded(child: card1),
                              const SizedBox(width: 16),
                              Expanded(child: card2),
                              const SizedBox(width: 16),
                              Expanded(child: card3),
                              const SizedBox(width: 16),
                              Expanded(child: card4),
                            ],
                          )
                        else
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: card1),
                                  const SizedBox(width: 12),
                                  Expanded(child: card2),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: card3),
                                  const SizedBox(width: 12),
                                  Expanded(child: card4),
                                ],
                              ),
                            ],
                          ),
                        
                        const SizedBox(height: 32),
                        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 16),
                        
                        AdminQuickAction(
                          icon: Icons.shield_outlined,
                          label: 'Review Pending Listings',
                          count: '$pendingCount',
                          iconColor: Colors.amber.shade600,
                          bgColor: Colors.orange.shade50.withOpacity(0.5),
                        ),
                        AdminQuickAction(
                          icon: Icons.report_gmailerrorred_outlined,
                          label: 'Flagged Reports',
                          count: '$reportsCount',
                          iconColor: Colors.red.shade400,
                          bgColor: Colors.red.shade50.withOpacity(0.5),
                        ),
                        
                        const SizedBox(height: 32),
                        const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 16),
                        
                        ..._buildRecentActivity(allDocs, reportsSnapshot),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  List<Widget> _buildRecentActivity(List<QueryDocumentSnapshot<Object?>> allDocs, AsyncSnapshot<QuerySnapshot> reportsSnapshot) {
    final listings = allDocs.take(10).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? 'pending';
      String statusPrefix = 'New';
      if (status == 'active') statusPrefix = 'Approved';
      if (status == 'rejected') statusPrefix = 'Rejected';
      
      return {
        'type': 'listing',
        'title': '$statusPrefix listing: ${data['title']}',
        'time': data['createdAt'] as Timestamp?,
        'color': status == 'active' ? Colors.green : status == 'rejected' ? Colors.red : Colors.amber,
      };
    }).toList();

    final reports = (reportsSnapshot.hasData ? reportsSnapshot.data!.docs : <QueryDocumentSnapshot<Object?>>[]).take(10).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'type': 'report',
        'title': 'Report: ${data['category'] ?? 'Flagged item'}',
        'time': data['createdAt'] as Timestamp?,
        'color': Colors.red,
      };
    }).toList();

    final combined = [...listings, ...reports];
    combined.sort((a, b) {
      final tA = (a['time'] as Timestamp?)?.toDate() ?? DateTime(2000);
      final tB = (b['time'] as Timestamp?)?.toDate() ?? DateTime(2000);
      return tB.compareTo(tA);
    });

    if (combined.isEmpty) {
      return [
        const Center(child: Text('No recent activity', style: TextStyle(color: Colors.grey)))
      ];
    }

    return combined.take(5).map((act) => AdminActivityItem(
      dotColor: act['color'] as Color,
      title: act['title'] as String,
      time: _timeAgo((act['time'] as Timestamp?)?.toDate() ?? DateTime.now()),
    )).toList();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
