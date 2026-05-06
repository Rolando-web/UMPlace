import 'package:flutter/material.dart';
import '../widgets/help_support_widgets.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Help & Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text("We're here to help you", style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.green.shade700,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.green.shade700,
              tabs: const [
                Tab(text: 'FAQs'),
                Tab(text: 'Contact\nSupport'),
                Tab(text: 'Guidelines'),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFaqsTab(),
                  const Center(child: Text('Contact Support coming soon')),
                  const Center(child: Text('Guidelines coming soon')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqsTab() {
    return Column(
      children: [
        // Category Chips
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              FaqChip(label: 'All', isSelected: true),
              FaqChip(label: 'Getting Started', isSelected: false),
              FaqChip(label: 'Buying', isSelected: false),
              FaqChip(label: 'Selling', isSelected: false),
              FaqChip(label: 'Safety', isSelected: false),
            ],
          ),
        ),
        // FAQ List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FaqItem(category: 'Getting Started', question: 'How do I verify my UM student account?'),
              FaqItem(category: 'Buying', question: 'How does the payment system work?'),
              FaqItem(category: 'Buying', question: 'What if the item is not as described?'),
              FaqItem(category: 'Selling', question: 'How much commission does UMPlace charge?'),
              FaqItem(category: 'Selling', question: 'When will I receive my payment?'),
              FaqItem(category: 'Safety', question: 'Where should I meet buyers/sellers?'),
              FaqItem(category: 'Safety', question: 'What should I do if I suspect a scam?'),
            ],
          ),
        ),
      ],
    );
  }

}
