import 'package:flutter/material.dart';
import '../screens/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final String category;
  final String title;
  final String price;
  final bool isNegotiable;
  final String sellerInitials;
  final String sellerName;
  final String rating;
  final String time;
  final Color imageFallbackColor;
  final String? listingId;
  final String? sellerId;
  final String? description;
  final String? condition;
  final List<String> images;

  const ProductCard({
    super.key,
    required this.category,
    required this.title,
    required this.price,
    required this.isNegotiable,
    required this.sellerInitials,
    required this.sellerName,
    required this.rating,
    required this.time,
    required this.imageFallbackColor,
    this.listingId,
    this.sellerId,
    this.description,
    this.condition,
    this.images = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(
          title: title,
          price: price,
          category: category,
          description: description ?? 'No description available.',
          condition: condition ?? 'Good',
          sellerId: sellerId ?? '',
          sellerName: sellerName,
          sellerInitials: sellerInitials,
          isNegotiable: isNegotiable,
          images: images,
          listingId: listingId ?? '',
        )));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: imageFallbackColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    if (images.isNotEmpty)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            images[0],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(Icons.broken_image, size: 40, color: Colors.grey.shade500),
                            ),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Icon(
                          category == 'Books' || category == 'Books & Notes' ? Icons.menu_book
                            : category == 'Electronics' ? Icons.devices
                            : category == 'Clothing' ? Icons.checkroom
                            : category == 'Food' ? Icons.restaurant
                            : Icons.shopping_bag,
                          size: 40, color: Colors.grey.shade500,
                        ),
                      ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB11A23).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Content Area
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(price, style: const TextStyle(color: Color(0xFFB11A23), fontWeight: FontWeight.bold, fontSize: 15)),
                        if (isNegotiable) const SizedBox(width: 4),
                        if (isNegotiable) const Text('Negotiable', style: TextStyle(color: Colors.green, fontSize: 10)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        CircleAvatar(radius: 10, backgroundColor: Colors.grey, child: Text(sellerInitials, style: const TextStyle(color: Colors.white, fontSize: 10))),
                        const SizedBox(width: 4),
                        Expanded(child: Text(sellerName, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        Text(rating, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
