import 'package:flutter/material.dart';

class ReasonOption extends StatelessWidget {
  final Map<String, dynamic> reason;
  final bool isSelected;
  final VoidCallback onTap;

  const ReasonOption({
    super.key,
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFFB11A23) : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(reason['icon'], color: reason['color']),
            const SizedBox(width: 16),
            Expanded(child: Text(reason['title'], style: const TextStyle(fontSize: 14))),
          ],
        ),
      ),
    );
  }
}
