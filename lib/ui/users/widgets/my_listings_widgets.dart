import 'package:flutter/material.dart';

class ListingStatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color bgColor;
  final bool isValueGreen;

  const ListingStatBox({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.bgColor,
    this.isValueGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: isValueGreen ? Colors.green : const Color(0xFFB11A23)),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isValueGreen ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class ListingTab extends StatelessWidget {
  final String label;
  final bool isSelected;

  const ListingTab({super.key, required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected ? const Color(0xFFB11A23) : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFFB11A23) : Colors.grey.shade600,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class ListingCard extends StatelessWidget {
  final String title;
  final String price;
  final String views;
  final String likes;
  final String offers;
  final String status;
  final String? imageUrl;
  final bool isSingleImage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ListingCard({
    super.key,
    required this.title,
    required this.price,
    required this.views,
    required this.likes,
    required this.offers,
    this.status = 'active',
    this.imageUrl,
    this.isSingleImage = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image, color: Colors.grey)),
                        )
                      : isSingleImage
                          ? const Center(child: Icon(Icons.image, color: Colors.grey))
                          : Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(child: Container(color: Colors.grey.shade300, margin: const EdgeInsets.all(2))),
                                      Expanded(child: Container(color: Colors.grey.shade300, margin: const EdgeInsets.all(2))),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(child: Container(color: Colors.grey.shade300, margin: const EdgeInsets.all(2))),
                                      Expanded(child: Container(color: Colors.grey.shade300, margin: const EdgeInsets.all(2))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: status == 'active' 
                                ? Colors.green.shade50 
                                : status == 'pending' 
                                    ? Colors.orange.shade50 
                                    : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: status == 'active' 
                                  ? Colors.green.shade700 
                                  : status == 'pending' 
                                      ? Colors.orange.shade700 
                                      : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(price, style: const TextStyle(color: Color(0xFFB11A23), fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.visibility_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(views, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.favorite_outline, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(likes, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.trending_up, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(offers, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              Column(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                      child: const Icon(Icons.edit_outlined, size: 16, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                      child: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('View', style: TextStyle(color: Colors.black87)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Mark as Sold', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
