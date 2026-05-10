import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/listing.dart';
import '../../../models/user_model.dart';
import '../../services/auth_service.dart';

// --- Events ---
abstract class CreateListingEvent extends Equatable {
  const CreateListingEvent();

  @override
  List<Object?> get props => [];
}

class CreateListingSubmitted extends CreateListingEvent {
  final Listing? existingListing;
  final String title;
  final String description;
  final double price;
  final String category;
  final String condition;
  final List<XFile> images;

  const CreateListingSubmitted({
    this.existingListing,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.images,
  });

  @override
  List<Object?> get props => [existingListing, title, description, price, category, condition, images];
}

// --- States ---
abstract class CreateListingState extends Equatable {
  const CreateListingState();

  @override
  List<Object?> get props => [];
}

class CreateListingInitial extends CreateListingState {}

class CreateListingLoading extends CreateListingState {}

class CreateListingSuccess extends CreateListingState {
  final String message;
  const CreateListingSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CreateListingFailure extends CreateListingState {
  final String error;
  const CreateListingFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// --- Bloc ---
class CreateListingBloc extends Bloc<CreateListingEvent, CreateListingState> {
  CreateListingBloc() : super(CreateListingInitial()) {
    on<CreateListingSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(CreateListingSubmitted event, Emitter<CreateListingState> emit) async {
    emit(CreateListingLoading());

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const CreateListingFailure('User not logged in'));
        return;
      }

      final collection = FirebaseFirestore.instance.collection('listings');
      final email = user.email ?? '';
      final displayName = user.displayName ?? '';
      String sellerName = '';
      if (email.isNotEmpty) {
        sellerName = email.split('@')[0];
      } else if (displayName.isNotEmpty) {
        sellerName = displayName;
      }

      final listingData = {
        'title': event.title,
        'description': event.description,
        'price': event.price,
        'category': event.category,
        'condition': event.condition,
        'sellerId': user.uid,
        'sellerEmail': email,
        'sellerName': sellerName,
        'images': event.existingListing?.images ?? [],
        'status': event.existingListing == null ? 'pending' : event.existingListing!.status,
        'createdAt': event.existingListing?.createdAt != null ? Timestamp.fromDate(event.existingListing!.createdAt) : FieldValue.serverTimestamp(),
        'views': event.existingListing?.views ?? 0,
        'likes': event.existingListing?.likes ?? 0,
        'offers': event.existingListing?.offers ?? 0,
      };

      if (event.existingListing == null) {
        // Enforce Trust Score limits for new listings
        final userData = await AuthService().getUserData();
        if (userData == null) {
          emit(const CreateListingFailure('Could not fetch user data'));
          return;
        }

        final limit = userData.listingLimit;
        if (limit == 0) {
          emit(const CreateListingFailure('Your trust score is too low to post new listings. Contact support to resolve issues.'));
          return;
        }

        // Check if payment methods are set up (Required for receiving escrow payouts)
        if (userData.paymentMethods == null || userData.paymentMethods!.isEmpty) {
          emit(const CreateListingFailure('Please set up your Payout Methods (GCash/Maya) in your Profile before listing an item. This ensures you can receive payments safely.'));
          return;
        }

        final existingListingsCount = await FirebaseFirestore.instance
            .collection('listings')
            .where('sellerId', isEqualTo: user.uid)
            .get()
            .then((snapshot) => snapshot.docs.length);

        if (existingListingsCount >= limit) {
          emit(CreateListingFailure(
              'Your current limit is $limit listings based on your trust score of ${userData.trustScore}. Verify your student ID or improve your score to list more.'));
          return;
        }

        // Create new
        final docRef = await collection.add(listingData).timeout(const Duration(seconds: 15));
        
        if (event.images.isNotEmpty) {
          final imageUrls = await _uploadImages(event.images, docRef.id).timeout(const Duration(seconds: 30));
          await docRef.update({'images': imageUrls}).timeout(const Duration(seconds: 15));
        }
        emit(const CreateListingSuccess('Listing submitted for review!'));
      } else {
        // Update
        await collection.doc(event.existingListing!.id).update(listingData).timeout(const Duration(seconds: 15));
        
        if (event.images.isNotEmpty) {
          final newUrls = await _uploadImages(event.images, event.existingListing!.id).timeout(const Duration(seconds: 30));
          final allUrls = List<String>.from(event.existingListing!.images)..addAll(newUrls);
          await collection.doc(event.existingListing!.id).update({'images': allUrls}).timeout(const Duration(seconds: 15));
        }
        emit(const CreateListingSuccess('Listing updated successfully!'));
      }
    } catch (e) {
      emit(CreateListingFailure(e.toString()));
    }
  }

  Future<List<String>> _uploadImages(List<XFile> images, String docId) async {
    final futures = images.map((xFile) async {
      return await CloudinaryService.uploadImage(xFile).timeout(const Duration(seconds: 25));
    });
    return await Future.wait(futures);
  }
}
