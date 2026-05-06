import 'package:flutter/material.dart';

class ConfirmPriceRow extends StatelessWidget {
  final String label;
  final String value;

  const ConfirmPriceRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }
}

class InstructionStep extends StatelessWidget {
  final String text;

  const InstructionStep({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
    );
  }
}
