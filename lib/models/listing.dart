import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  final String id;
  final String title;
  final double price;
  final String category;
  final String description;
  final String sellerId;
  final String sellerEmail;
  final String sellerName;
  final String condition;
  final List<String> images;
  final DateTime createdAt;
  final String status;
  final int views;
  final int likes;
  final int offers;

  Listing({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.description,
    required this.sellerId,
    this.sellerEmail = '',
    this.sellerName = '',
    required this.condition,
    this.images = const [],
    required this.createdAt,
    required this.status,
    this.views = 0,
    this.likes = 0,
    this.offers = 0,
  });

  factory Listing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return Listing.empty(doc.id);
    }
    return Listing(
      id: doc.id,
      title: data['title'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      sellerId: data['sellerId'] ?? '',
      sellerEmail: data['sellerEmail'] ?? '',
      sellerName: data['sellerName'] ?? '',
      condition: data['condition'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'active',
      views: data['views'] ?? 0,
      likes: data['likes'] ?? 0,
      offers: data['offers'] ?? 0,
    );
  }

  factory Listing.empty(String id) {
    return Listing(
      id: id,
      title: '',
      price: 0,
      category: '',
      description: '',
      sellerId: '',
      condition: 'New',
      images: [],
      createdAt: DateTime.now(),
      status: 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'category': category,
      'description': description,
      'sellerId': sellerId,
      'sellerEmail': sellerEmail,
      'sellerName': sellerName,
      'condition': condition,
      'images': images,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'views': views,
      'likes': likes,
      'offers': offers,
    };
  }
}
