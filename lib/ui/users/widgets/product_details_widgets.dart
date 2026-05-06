import 'package:flutter/material.dart';

class CarouselDot extends StatelessWidget {
  final bool isActive;

  const CarouselDot({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFB11A23) : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}

class DetailTag extends StatelessWidget {
  final String text;

  const DetailTag({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
    );
  }
}
