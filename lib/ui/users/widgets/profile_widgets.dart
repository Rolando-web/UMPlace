import 'package:flutter/material.dart';

class ProfileStatColumn extends StatelessWidget {
  final String value;
  final String label;

  const ProfileStatColumn({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}

class ProfileMenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ProfileMenuCard({super.key, required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFB11A23).withOpacity(0.06), // Fade Maroon
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFB11A23).withOpacity(0.12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFB11A23), size: 26),
              const SizedBox(height: 8),
              Text(
                label, 
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB11A23),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrustProgress extends StatelessWidget {
  final String label;
  final String percentage;
  final double value;

  const TrustProgress({super.key, required this.label, required this.percentage, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            Text(percentage, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey.shade200,
          color: Colors.green,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}
