import 'package:flutter/material.dart';

class FaqChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const FaqChip({super.key, required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green.shade700 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class FaqItem extends StatelessWidget {
  final String category;
  final String question;

  const FaqItem({super.key, required this.category, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Colors.grey.shade600,
          collapsedIconColor: Colors.grey.shade600,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.help_outline, color: Colors.green.shade700, size: 14),
                  const SizedBox(width: 4),
                  Text(category, style: TextStyle(color: Colors.green.shade700, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                question,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                'This is a placeholder answer for the question: $question. You can expand on this later.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            )
          ],
        ),
      ),
    );
  }
}
