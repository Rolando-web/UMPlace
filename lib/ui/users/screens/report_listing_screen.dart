import 'package:flutter/material.dart';
import '../widgets/report_listing_widgets.dart';

class ReportListingScreen extends StatefulWidget {
  const ReportListingScreen({super.key});

  @override
  State<ReportListingScreen> createState() => _ReportListingScreenState();
}

class _ReportListingScreenState extends State<ReportListingScreen> {
  String? _selectedReason;

  final List<Map<String, dynamic>> _reasons = [
    {'icon': Icons.search, 'title': 'Selling Lost & Found Items', 'color': Colors.grey.shade700},
    {'icon': Icons.local_police_outlined, 'title': 'Suspected Stolen Item', 'color': Colors.red},
    {'icon': Icons.warning_amber_rounded, 'title': 'Fraudulent Listing', 'color': Colors.amber},
    {'icon': Icons.block, 'title': 'Inappropriate Content', 'color': Colors.red.shade700},
    {'icon': Icons.email_outlined, 'title': 'Spam or Duplicate', 'color': Colors.blue.shade300},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Report Listing', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Warning Block
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                            children: const [
                              TextSpan(text: 'Important: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: 'False reports may result in account suspension. Only report genuine concerns.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Listing Preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reporting Listing:', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('HP Laptop Charger 65W Type-C', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('Seller: Juan Diaz', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                const SizedBox(height: 2),
                                const Text('₱800', style: TextStyle(color: Color(0xFFB11A23), fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                const Text('Why are you reporting this listing?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                
                ..._reasons.map((reason) {
                  return ReasonOption(
                    reason: reason,
                    isSelected: _selectedReason == reason['title'],
                    onTap: () {
                      setState(() {
                        _selectedReason = reason['title'];
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          
          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedReason != null ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade300,
                      disabledBackgroundColor: Colors.red.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Submit Report', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Your identity will be kept confidential', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
