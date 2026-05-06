import 'package:flutter/material.dart';

class ConditionButton extends StatelessWidget {
  final String label;

  const ConditionButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
    );
  }
}
