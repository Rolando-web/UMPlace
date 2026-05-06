import 'package:flutter/material.dart';
import '../widgets/secure_payment_widgets.dart';

class SecurePaymentScreen extends StatelessWidget {
  final String itemTitle;
  final String price;
  final String sellerName;

  const SecurePaymentScreen({
    super.key,
    required this.itemTitle,
    required this.price,
    required this.sellerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB11A23), // UM Maroon
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Secure Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Escrow Protected', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.shield_outlined, color: Colors.amber), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Protection Banner
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.amber.shade50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Payment is Protected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          "UMPlace holds your payment securely in escrow until you confirm receipt of the item. Seller only gets paid after you're satisfied.",
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  
                  // Order Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(itemTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                            Text('Seller: $sellerName (5.0', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            const Icon(Icons.star, color: Colors.amber, size: 12),
                            Text(')', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        PaymentPriceRow(label: 'Item Price', value: price),
                        const SizedBox(height: 8),
                        const PaymentPriceRow(label: 'Platform Fee', value: '₱30.00'),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(price, style: const TextStyle(color: Color(0xFFB11A23), fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final numericPrice = double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                            final sellerReceives = (numericPrice - 30).clamp(0, double.infinity);
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                              child: Row(
                                children: [
                                  Icon(Icons.lightbulb_outline, color: Colors.green.shade700, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Seller receives: ₱${sellerReceives.toStringAsFixed(2)} (after commission)', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                                ],
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  
                  // Payment Methods
                  PaymentMethodTile(title: 'GCash', subtitle: 'Pay via GCash e-wallet', color: Colors.blue, initial: 'G'),
                  const SizedBox(height: 12),
                  PaymentMethodTile(title: 'Maya (PayMaya)', subtitle: 'Pay via Maya e-wallet', color: Colors.green, initial: 'M'),
                  
                  const SizedBox(height: 24),
                  
                  // Footer Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline, color: Colors.grey.shade600, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'All payments are secured with escrow protection. Your money is only released to the seller after you confirm receipt.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
