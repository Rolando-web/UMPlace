import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_widgets.dart';
import '../../../../models/transaction.dart';

class RevenueTab extends StatelessWidget {
  const RevenueTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('transactions').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactionDocs = snapshot.hasData ? snapshot.data!.docs : [];
        final transactions = transactionDocs.map((doc) => TransactionModel.fromFirestore(doc)).toList();

        double totalSales = 0;
        double totalCommission = 0;
        
        Map<String, double> categoryCommission = {};
        Map<int, double> monthlyCommission = {}; // last 7 months

        DateTime now = DateTime.now();
        // Generate last 7 months labels and start dates
        List<DateTime> monthDates = List.generate(7, (i) => DateTime(now.year, now.month - (6 - i), 1));
        List<String> monthLabels = monthDates.map((d) => DateFormat('MMM').format(d)).toList();

        for (var tx in transactions) {
          totalSales += tx.amount;
          totalCommission += tx.commission;

          // Category Breakdown
          categoryCommission[tx.category] = (categoryCommission[tx.category] ?? 0) + tx.commission;

          // Monthly Trend
          for (int i = 0; i < 7; i++) {
            if (tx.createdAt.year == monthDates[i].year && tx.createdAt.month == monthDates[i].month) {
              monthlyCommission[i] = (monthlyCommission[i] ?? 0) + tx.commission;
              break;
            }
          }
        }

        final avgCommission = transactions.isNotEmpty ? totalCommission / transactions.length : 0;

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Top Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                final card1 = AdminRevenueCard(
                  bgColor: const Color(0xFFB11A23),
                  leadingIcon: Icons.account_balance_wallet,
                  amount: '₱${totalCommission.toStringAsFixed(2)}',
                  title: 'Total Commission Earned',
                  subtitle: 'Platform revenue share',
                  trailingIcon: Icons.trending_up,
                );
                final card2 = AdminRevenueCard(
                  bgColor: Colors.amber.shade600,
                  leadingIcon: Icons.point_of_sale,
                  amount: '₱${totalSales.toStringAsFixed(2)}',
                  title: 'Total Sales Volume',
                  subtitle: '${transactions.length} total transactions',
                  trailingIcon: Icons.calendar_today_outlined,
                );
                final card3 = AdminRevenueCard(
                  bgColor: Colors.green.shade700,
                  leadingIcon: Icons.insights,
                  amount: '₱${avgCommission.toStringAsFixed(2)}',
                  title: 'Avg. Commission/TX',
                  subtitle: 'Per transaction average',
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

            // Commission Breakdown & Pie Chart
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                
                final breakdown = _buildSectionCard(
                  title: 'Commission by Category',
                  child: Column(
                    children: [
                      _buildCategoryRow(categoryCommission, 'Books & Notes', const Color(0xFFB11A23)),
                      _buildCategoryRow(categoryCommission, 'Electronics', Colors.amber),
                      _buildCategoryRow(categoryCommission, 'Food', Colors.orange),
                      _buildCategoryRow(categoryCommission, 'Clothing', Colors.green),
                      _buildCategoryRow(categoryCommission, 'Others', Colors.grey),
                    ],
                  ),
                );

                final pieChart = _buildSectionCard(
                  title: 'Category Revenue Share',
                  height: 300,
                  child: categoryCommission.isEmpty 
                    ? const Center(child: Text('No data available', style: TextStyle(color: Colors.grey)))
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: _generatePieSections(categoryCommission),
                        ),
                      ),
                );

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: breakdown),
                      const SizedBox(width: 24),
                      Expanded(flex: 3, child: pieChart),
                    ],
                  );
                }
                return Column(children: [breakdown, const SizedBox(height: 24), pieChart]);
              },
            ),

            const SizedBox(height: 24),

            // Monthly Revenue Trend
            _buildSectionCard(
              title: 'Monthly Commission Trend',
              height: 300,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (LineBarSpot touchedSpot) => Colors.blueGrey.shade800,
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          return LineTooltipItem(
                            '₱${touchedSpot.y.toStringAsFixed(2)}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                    getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => _bottomTitleWidgets(value, meta, monthLabels),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text('₱${value.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateLineSpots(monthlyCommission),
                      isCurved: true,
                      color: const Color(0xFFB11A23),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFFB11A23).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  Widget _buildCategoryRow(Map<String, double> data, String category, Color color) {
    final value = data[category] ?? 0;
    return AdminCommissionRow(
      dotColor: color,
      label: category,
      value: '₱${value.toStringAsFixed(2)}',
    );
  }

  List<PieChartSectionData> _generatePieSections(Map<String, double> data) {
    final colors = {
      'Books & Notes': const Color(0xFFB11A23),
      'Electronics': Colors.amber,
      'Food': Colors.orange,
      'Clothing': Colors.green,
      'Others': Colors.grey,
    };

    if (data.isEmpty) return [];

    return data.entries.map((entry) {
      final color = colors[entry.key] ?? Colors.blueGrey;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: entry.key,
        radius: 60,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  List<FlSpot> _generateLineSpots(Map<int, double> data) {
    return List.generate(7, (i) => FlSpot(i.toDouble(), data[i] ?? 0));
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

  Widget _bottomTitleWidgets(double value, TitleMeta meta, List<String> labels) {
    final index = value.toInt();
    if (index >= 0 && index < labels.length) {
      return SideTitleWidget(
        meta: meta,
        child: Text(labels[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
      );
    }
    return const SizedBox.shrink();
  }
}
