import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

abstract class BookingRepository {
  Future<String> createBooking(BookingModel booking);
  Future<void> updateBooking(BookingModel booking);
  Future<BookingModel?> getBookingById(String id);
  Future<List<BookingModel>> getBookingsByCargoOwner(String cargoOwnerId);
  Future<List<BookingModel>> getBookingsByDriver(String driverId);
  Future<List<BookingModel>> getPendingBookingsForDriver(String driverId);
  Stream<List<BookingModel>> getBookingsStreamByCargoOwner(String cargoOwnerId);
  Stream<List<BookingModel>> getBookingsStreamByDriver(String driverId);
  Stream<List<BookingModel>> getPendingBookingsStreamForDriver(String driverId);
  Future<void> acceptBooking(String bookingId, String driverId);
  Future<void> declineBooking(String bookingId, String driverId);
  Future<void> completeBooking(String bookingId);
  Future<void> cancelBooking(String bookingId);
  Future<void> reassignBooking(String bookingId);
}

class FirebaseBookingRepository implements BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'bookings';

  @override
  Future<String> createBooking(BookingModel booking) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(booking.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  @override
  Future<void> updateBooking(BookingModel booking) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(booking.id)
          .update(booking.toFirestore());
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  @override
  Future<BookingModel?> getBookingById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return BookingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  @override
  Future<List<BookingModel>> getBookingsByCargoOwner(String cargoOwnerId) async {
    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('cargoOwnerId', isEqualTo: cargoOwnerId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get bookings by cargo owner: $e');
    }
  }

  @override
  Future<List<BookingModel>> getBookingsByDriver(String driverId) async {
    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get bookings by driver: $e');
    }
  }

  @override
  Future<List<BookingModel>> getPendingBookingsForDriver(String driverId) async {
    try {
      // Get all pending bookings where the driver hasn't been assigned yet
      // or where this specific driver was selected but hasn't responded
      final query = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get pending bookings for driver: $e');
    }
  }

  @override
  Stream<List<BookingModel>> getBookingsStreamByCargoOwner(String cargoOwnerId) {
    return _firestore
        .collection(_collectionName)
        .where('cargoOwnerId', isEqualTo: cargoOwnerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BookingModel.fromFirestore(doc))
        .toList());
  }

  @override
  Stream<List<BookingModel>> getBookingsStreamByDriver(String driverId) {
    return _firestore
        .collection(_collectionName)
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BookingModel.fromFirestore(doc))
        .toList());
  }

  @override
  Stream<List<BookingModel>> getPendingBookingsStreamForDriver(String driverId) {
    return _firestore
        .collection(_collectionName)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BookingModel.fromFirestore(doc))
        .toList());
  }

  @override
  Future<void> acceptBooking(String bookingId, String driverId) async {
    try {
      await _firestore.collection(_collectionName).doc(bookingId).update({
        'driverId': driverId,
        'status': BookingStatus.accepted.toString().split('.').last,
        'acceptedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to accept booking: $e');
    }
  }

  @override
  Future<void> declineBooking(String bookingId, String driverId) async {
    try {
      await _firestore.collection(_collectionName).doc(bookingId).update({
        'status': BookingStatus.declined.toString().split('.').last,
        'driverId': driverId, // Keep track of who declined
      });
    } catch (e) {
      throw Exception('Failed to decline booking: $e');
    }
  }

  @override
  Future<void> completeBooking(String bookingId) async {
    try {
      await _firestore.collection(_collectionName).doc(bookingId).update({
        'status': BookingStatus.completed.toString().split('.').last,
        'completedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to complete booking: $e');
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection(_collectionName).doc(bookingId).update({
        'status': BookingStatus.cancelled.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  @override
  Future<void> reassignBooking(String bookingId) async {
    try {
      await _firestore.collection(_collectionName).doc(bookingId).update({
        'status': BookingStatus.pending.toString().split('.').last,
        'driverId': null,
        'acceptedAt': null,
      });
    } catch (e) {
      throw Exception('Failed to reassign booking: $e');
    }
  }
}