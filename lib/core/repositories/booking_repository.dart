import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../enums/app_enums.dart';

abstract class BookingRepository {
  Future<String> createBooking(Booking booking);
  Future<Booking?> getBookingById(String bookingId);
  Future<void> updateBooking(Booking booking);
  Future<void> deleteBooking(String bookingId);
  Future<List<Booking>> getBookingsByCargoOwner(String cargoOwnerId);
  Future<List<Booking>> getBookingsByDriver(String driverId);
  Future<List<Booking>> getAvailableBookings();
  Stream<Booking?> bookingStream(String bookingId);
  Stream<List<Booking>> bookingsStream({
    String? cargoOwnerId,
    String? driverId,
  });
}

class FirebaseBookingRepository implements BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'bookings';

  @override
  Future<String> createBooking(Booking booking) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .add(booking.toMap());
      return doc.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  @override
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(bookingId)
          .get();
      if (doc.exists) {
        return Booking.fromMap({...doc.data()!, 'bookingId': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  @override
  Future<void> updateBooking(Booking booking) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(booking.bookingId)
          .update(booking.toMap());
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  @override
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection(_collectionName).doc(bookingId).delete();
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  @override
  Future<List<Booking>> getBookingsByCargoOwner(String cargoOwnerId) async {
    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('cargoOwnerId', isEqualTo: cargoOwnerId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => Booking.fromMap({...doc.data(), 'bookingId': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get bookings by cargo owner: $e');
    }
  }

  @override
  Future<List<Booking>> getBookingsByDriver(String driverId) async {
    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => Booking.fromMap({...doc.data(), 'bookingId': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get bookings by driver: $e');
    }
  }

  @override
  Future<List<Booking>> getAvailableBookings() async {
    try {
      final query = await _firestore
          .collection(_collectionName)
          .where(
            'status',
            isEqualTo: BookingStatus.pending.toString().split('.').last,
          )
          .where('driverId', isNull: true)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => Booking.fromMap({...doc.data(), 'bookingId': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get available bookings: $e');
    }
  }

  @override
  Stream<Booking?> bookingStream(String bookingId) {
    return _firestore
        .collection(_collectionName)
        .doc(bookingId)
        .snapshots()
        .map(
          (doc) => doc.exists
              ? Booking.fromMap({...doc.data()!, 'bookingId': doc.id})
              : null,
        );
  }

  @override
  Stream<List<Booking>> bookingsStream({
    String? cargoOwnerId,
    String? driverId,
  }) {
    Query query = _firestore.collection(_collectionName);

    if (cargoOwnerId != null) {
      query = query.where('cargoOwnerId', isEqualTo: cargoOwnerId);
    }

    if (driverId != null) {
      query = query.where('driverId', isEqualTo: driverId);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Booking.fromMap({
                  ...doc.data() as Map<String, dynamic>,
                  'bookingId': doc.id,
                }),
              )
              .toList(),
        );
  }
}
