import 'package:flutter/material.dart';
import 'secure_payment_screen.dart';
import '../widgets/confirm_purchase_widgets.dart';

class ConfirmPurchaseScreen extends StatelessWidget {
  final String itemTitle;
  final String price;
  final String sellerName;
  final String sellerId;
  final String listingId;
  final String category;

  const ConfirmPurchaseScreen({
    super.key,
    required this.itemTitle,
    required this.price,
    required this.sellerName,
    required this.sellerId,
    required this.listingId,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54, // Dim background to simulate bottom sheet or dialog
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Confirm Purchase', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(itemTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text('by $sellerName', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 14),
                                      const SizedBox(width: 4),
                                      const Text('4.2', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Payment Breakdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Payment Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 12),
                            ConfirmPriceRow(label: 'Item Price', value: price),
                            const SizedBox(height: 8),
                            const ConfirmPriceRow(label: 'Platform Fee (Flat)', value: '₱30.00'),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(price, style: const TextStyle(color: Color(0xFFB11A23), fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                final numericPrice = double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                                final sellerReceives = (numericPrice - 30).clamp(0, double.infinity);
                                return Text('Seller receives: ₱${sellerReceives.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12));
                              }
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Escrow Protection
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.shield_outlined, color: Colors.amber, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Escrow Protection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Your payment is held securely until you confirm receipt of the item. Money is only released to the seller after you're satisfied.",
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // What happens next
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('What happens next?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 8),
                            InstructionStep(text: '1. You\'ll be redirected to payment screen'),
                            InstructionStep(text: '2. Pay via GCash or Maya'),
                            InstructionStep(text: '3. Funds held safely in escrow'),
                            InstructionStep(text: '4. Coordinate meet-up with seller'),
                            InstructionStep(text: '5. Meet at Safe Zone on campus'),
                            InstructionStep(text: '6. Inspect item before confirming'),
                            InstructionStep(text: '7. Confirm receipt to release payment'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: Colors.grey.shade300),
                                backgroundColor: Colors.grey.shade50,
                              ),
                              child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SecurePaymentScreen(
                                  itemTitle: itemTitle,
                                  price: price,
                                  sellerName: sellerName,
                                  sellerId: sellerId,
                                  listingId: listingId,
                                  category: category,
                                )));
                              },
                              icon: const Icon(Icons.attach_money, color: Colors.white, size: 18),
                              label: const Text('Proceed to\nPayment', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, height: 1.2)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB11A23),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
