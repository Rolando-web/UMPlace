import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Events ---
abstract class ManageListingsEvent extends Equatable {
  const ManageListingsEvent();

  @override
  List<Object?> get props => [];
}

class UpdateListingStatus extends ManageListingsEvent {
  final String id;
  final String newStatus;
  final String? reason;

  const UpdateListingStatus(this.id, this.newStatus, {this.reason});

  @override
  List<Object?> get props => [id, newStatus, reason];
}

class DeleteListing extends ManageListingsEvent {
  final String id;

  const DeleteListing(this.id);

  @override
  List<Object?> get props => [id];
}

// --- States ---
abstract class ManageListingsState extends Equatable {
  const ManageListingsState();

  @override
  List<Object?> get props => [];
}

class ManageListingsInitial extends ManageListingsState {}

class ManageListingsLoading extends ManageListingsState {}

class ManageListingsSuccess extends ManageListingsState {
  final String message;
  const ManageListingsSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ManageListingsFailure extends ManageListingsState {
  final String error;
  const ManageListingsFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// --- Bloc ---
class ManageListingsBloc extends Bloc<ManageListingsEvent, ManageListingsState> {
  ManageListingsBloc() : super(ManageListingsInitial()) {
    on<UpdateListingStatus>(_onUpdateStatus);
    on<DeleteListing>(_onDeleteListing);
  }

  Future<void> _onUpdateStatus(UpdateListingStatus event, Emitter<ManageListingsState> emit) async {
    emit(ManageListingsLoading());
    try {
      await FirebaseFirestore.instance.collection('listings').doc(event.id).update({
        'status': event.newStatus,
        if (event.reason != null) 'rejectionReason': event.reason,
      }).timeout(const Duration(seconds: 15));
      emit(ManageListingsSuccess('Listing ${event.newStatus == 'active' ? 'approved' : 'rejected'} successfully!'));
    } catch (e) {
      emit(ManageListingsFailure(e.toString()));
    }
  }

  Future<void> _onDeleteListing(DeleteListing event, Emitter<ManageListingsState> emit) async {
    emit(ManageListingsLoading());
    try {
      await FirebaseFirestore.instance.collection('listings').doc(event.id).delete().timeout(const Duration(seconds: 15));
      emit(const ManageListingsSuccess('Listing deleted by admin'));
    } catch (e) {
      emit(ManageListingsFailure(e.toString()));
    }
  }
}
