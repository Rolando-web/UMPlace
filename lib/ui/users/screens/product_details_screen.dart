import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'confirm_purchase_screen.dart';
import 'report_listing_screen.dart';
import '../../../services/chat_service.dart';
import '../widgets/product_details_widgets.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String title;
  final String price;
  final String category;
  final String description;
  final String condition;
  final String sellerId;
  final String sellerName;
  final String sellerInitials;
  final bool isNegotiable;
  final List<String> images;
  final String listingId;

  const ProductDetailsScreen({
    super.key,
    required this.title,
    required this.price,
    required this.category,
    required this.description,
    required this.condition,
    required this.sellerId,
    required this.sellerName,
    required this.sellerInitials,
    required this.isNegotiable,
    required this.listingId,
    this.images = const [],
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(icon: const Icon(Icons.share, color: Colors.black), onPressed: () {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.black), onPressed: () {}),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.images.isNotEmpty)
                    PageView.builder(
                      itemCount: widget.images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: Text('No images available', style: TextStyle(color: Colors.grey))),
                    ),
                  if (widget.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(widget.images.length, (index) {
                          return CarouselDot(isActive: index == _currentImageIndex);
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(widget.price, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFB11A23))),
                      if (widget.isNegotiable) const SizedBox(width: 8),
                      if (widget.isNegotiable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                          child: const Text('Negotiable', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      DetailTag(text: widget.category),
                      const SizedBox(width: 8),
                      DetailTag(text: widget.condition),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Seller Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFB11A23),
                              child: Text(widget.sellerInitials, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(child: Text(widget.sellerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check, size: 10, color: Colors.white),
                                            SizedBox(width: 2),
                                            Text('Verified', style: TextStyle(color: Colors.white, fontSize: 10)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 14),
                                      const SizedBox(width: 4),
                                      const Text('5.0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text(' Trust Score', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('UM Student', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            const Text('View Profile', style: TextStyle(color: Color(0xFFB11A23), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // padding for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(context),
    );
  }

  Widget? _buildBottomAction(BuildContext context) {
    final currentUserId = ChatService().currentUserId;
    final isOwner = widget.sellerId == currentUserId;

    if (isOwner) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Logic to edit listing
                  },
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFFB11A23)),
                  label: const Text('Edit Listing', style: TextStyle(color: Color(0xFFB11A23))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFB11A23)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Logic to delete listing
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  label: const Text('Delete', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportListingScreen()));
                },
                icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFB11A23)),
                label: const Text('Report', style: TextStyle(color: Color(0xFFB11A23))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFB11A23)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final chatService = ChatService();
                    final listingInfo = {
                      'title': widget.title,
                      'price': widget.price,
                      'imageUrl': widget.images.isNotEmpty ? widget.images[0] : null,
                    };

                    final chatRoomId = await chatService.getOrCreateChatRoom(
                      widget.sellerId,
                      widget.sellerName,
                      listingInfo,
                      widget.listingId,
                    );

                    if (context.mounted) {
                      Navigator.pop(context); // Close loading
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatRoomId: chatRoomId,
                            receiverId: widget.sellerId,
                            receiverName: widget.sellerName,
                            listingInfo: listingInfo,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error starting chat: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFFB11A23)),
                label: const Text('Chat with Seller', style: TextStyle(color: Color(0xFFB11A23))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFB11A23)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfirmPurchaseScreen(
                        itemTitle: widget.title,
                        price: widget.price,
                        sellerName: widget.sellerName,
                        sellerId: widget.sellerId,
                        listingId: widget.listingId,
                        category: widget.category,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB11A23),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Buy Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
