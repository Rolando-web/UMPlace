import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/admin_widgets.dart';

class RevenueTab extends StatelessWidget {
  const RevenueTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('transactions').snapshots(),
      builder: (context, snapshot) {
        final transactions = snapshot.hasData ? snapshot.data!.docs : [];
        double totalRevenue = 0;
        for (var doc in transactions) {
          totalRevenue += (doc.data() as Map<String, dynamic>)['amount'] ?? 0;
        }
        
        final commission = totalRevenue * 0.10; // 10% commission
        final avgCommission = transactions.isNotEmpty ? commission / transactions.length : 0;

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Top Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                final card1 = AdminRevenueCard(
                  bgColor: const Color(0xFFB11A23),
                  leadingIcon: Icons.attach_money,
                  amount: '₱${commission.toStringAsFixed(2)}',
                  title: 'Total Commission Earned',
                  subtitle: '+10% from all sales',
                  trailingIcon: Icons.trending_up,
                );
                final card2 = AdminRevenueCard(
                  bgColor: Colors.amber.shade600,
                  leadingIcon: Icons.attach_money,
                  amount: '₱${totalRevenue.toStringAsFixed(2)}',
                  title: 'Total Sales Revenue',
                  subtitle: '${transactions.length} total transactions',
                  trailingIcon: Icons.calendar_today_outlined,
                );
                final card3 = AdminRevenueCard(
                  bgColor: Colors.green.shade700,
                  leadingIcon: Icons.attach_money,
                  amount: '₱${avgCommission.toStringAsFixed(2)}',
                  title: 'Avg. Commission/Transaction',
                  subtitle: 'Based on platform rate',
                  trailingIcon: Icons.show_chart,
                );

                if (isDesktop) {
                  return Row(
                    children: [
                      Expanded(child: card1),
                      const SizedBox(width: 16),
                      Expanded(child: card2),
                      const SizedBox(width: 16),
                      Expanded(child: card3),
                    ],
                  );
                }
                return Column(children: [card1, card2, card3]);
              },
            ),

            const SizedBox(height: 24),

            // Commission Breakdown
            _buildSectionCard(
              title: 'Commission Breakdown',
              child: Column(
                children: [
                  const AdminCommissionRow(dotColor: Color(0xFFB11A23), label: 'Books & Notes', value: 'Dynamic data pending'),
                  const AdminCommissionRow(dotColor: Colors.amber, label: 'Electronics', value: 'Dynamic data pending'),
                  const AdminCommissionRow(dotColor: Colors.orange, label: 'Food', value: 'Dynamic data pending'),
                  const AdminCommissionRow(dotColor: Colors.green, label: 'Clothing', value: 'Dynamic data pending'),
                  const AdminCommissionRow(dotColor: Colors.grey, label: 'Others', value: 'Dynamic data pending'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Monthly Revenue Trend
            _buildSectionCard(
              title: 'Monthly Revenue Trend',
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: true),
                  titlesData: const FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _bottomTitleWidgets,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 0),
                        FlSpot(1, 0),
                        FlSpot(2, 0),
                        FlSpot(3, 0),
                        FlSpot(4, 0),
                        FlSpot(5, 0),
                        FlSpot(6, 0),
                      ],
                      isCurved: true,
                      color: const Color(0xFFB11A23),
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Category Revenue Pie Chart
            _buildSectionCard(
              title: 'Category Revenue',
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(color: const Color(0xFFB11A23), value: 100, title: 'No Data', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionCard({required String title, required Widget child, double? height}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (height != null) SizedBox(height: height, child: child) else child,
        ],
      ),
    );
  }

  static Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10);
    Widget text;
    switch (value.toInt()) {
      case 0: text = const Text('Oct', style: style); break;
      case 1: text = const Text('Nov', style: style); break;
      case 2: text = const Text('Dec', style: style); break;
      case 3: text = const Text('Jan', style: style); break;
      case 4: text = const Text('Feb', style: style); break;
      case 5: text = const Text('Mar', style: style); break;
      case 6: text = const Text('Apr', style: style); break;
      default: text = const Text('', style: style); break;
    }
    return SideTitleWidget(meta: meta, child: text);
  }
}
