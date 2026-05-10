import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/paymongo_service.dart';

class PaymentPriceRow extends StatelessWidget {
  final String label;
  final String value;

  const PaymentPriceRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      ],
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final String initial;
  final VoidCallback? onTap;

  const PaymentMethodTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.initial,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class PaymentSimulationDialog extends StatefulWidget {
  final String method;
  final String url;
  final String transactionId;
  final VoidCallback onSuccess;

  const PaymentSimulationDialog({
    super.key,
    required this.method,
    required this.url,
    required this.transactionId,
    required this.onSuccess,
  });

  @override
  State<PaymentSimulationDialog> createState() => _PaymentSimulationDialogState();
}

class _PaymentSimulationDialogState extends State<PaymentSimulationDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Paymongo ${widget.method}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('To complete your payment on your phone, you need to open the secure checkout page.'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : () async {
                final uri = Uri.parse(widget.url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open GCash/Maya Page'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text('After paying on the web page, return here and click "Payment Completed".', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context), 
          child: const Text('Cancel')
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : () async {
            setState(() => _isProcessing = true);
            try {
              await PaymongoService.updateTransactionStatus(widget.transactionId, 'paid');
              if (!mounted) return;
              Navigator.pop(context); // Close dialog
              widget.onSuccess();
            } catch (e) {
              if (mounted) {
                setState(() => _isProcessing = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          child: _isProcessing 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Payment Completed'),
        ),
      ],
    );
  }
}

class PaymentSuccessBottomSheet extends StatelessWidget {
  final String price;

  const PaymentSuccessBottomSheet({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
          const SizedBox(height: 24),
          const Text('Payment Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            'Your payment of $price is now held securely in Escrow.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                Text('Next Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('1. Message the seller to arrange pick-up.', textAlign: TextAlign.center),
                Text('2. Meet at a Safe Zone.', textAlign: TextAlign.center),
                Text('3. Confirm receipt in your "Transactions" to release funds.', textAlign: TextAlign.center),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close bottom sheet
                Navigator.pop(context); // Close SecurePaymentScreen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB11A23),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Back to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
