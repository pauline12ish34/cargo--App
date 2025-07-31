import 'package:flutter/material.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/repositories/booking_repository.dart';

class BookingProvider with ChangeNotifier {
  final BookingRepository _bookingRepository;

  BookingProvider(this._bookingRepository);

  List<BookingModel> _myBookings = [];
  List<BookingModel> _availableBookings = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get myBookings => _myBookings;
  List<BookingModel> get availableBookings => _availableBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Create a new booking
  Future<bool> createBooking({
    required String cargoOwnerId,
    required String pickupLocation,
    required String dropoffLocation,
    required String cargoDescription,
    required VehicleType vehicleType,
    double? weight,
    String? specialInstructions,
    double? estimatedPrice,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final booking = BookingModel(
        id: '',
        cargoOwnerId: cargoOwnerId,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        cargoDescription: cargoDescription,
        vehicleType: vehicleType,
        weight: weight,
        specialInstructions: specialInstructions,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        estimatedPrice: estimatedPrice,
      );

      final bookingId = await _bookingRepository.createBooking(booking);

      _myBookings.insert(0, booking.copyWith(id: bookingId));

      return true;
    } catch (e) {
      _setError('Failed to create booking: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load bookings for cargo owner
  Future<void> loadCargoOwnerBookings(String cargoOwnerId) async {
    try {
      _setLoading(true);
      _setError(null);
      _myBookings = await _bookingRepository.getBookingsByCargoOwner(cargoOwnerId);
    } catch (e) {
      _setError('Failed to load bookings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load bookings for driver
  Future<void> loadDriverBookings(String driverId) async {
    try {
      _setLoading(true);
      _setError(null);
      _myBookings = await _bookingRepository.getBookingsByDriver(driverId);
    } catch (e) {
      _setError('Failed to load driver bookings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load available bookings for driver
  Future<void> loadAvailableBookings(String driverId) async {
    try {
      _setLoading(true);
      _setError(null);
      _availableBookings = await _bookingRepository.getPendingBookingsForDriver(driverId);
    } catch (e) {
      _setError('Failed to load available bookings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Accept a booking
  Future<bool> acceptBooking(String bookingId, String driverId) async {
    try {
      _setLoading(true);
      _setError(null);
      await _bookingRepository.acceptBooking(bookingId, driverId);

      final index = _availableBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        final updated = _availableBookings[index].copyWith(
          status: BookingStatus.accepted,
          driverId: driverId,
          acceptedAt: DateTime.now(),
        );
        _availableBookings.removeAt(index);
        _myBookings.insert(0, updated);
      }

      return true;
    } catch (e) {
      _setError('Failed to accept booking: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Accept booking with chat
  Future<bool> acceptBookingWithChat(String bookingId, String driverId, String driverName) async {
    try {
      _setLoading(true);
      _setError(null);
      await _bookingRepository.acceptBooking(bookingId, driverId);

      final index = _availableBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        final updated = _availableBookings[index].copyWith(
          status: BookingStatus.accepted,
          driverId: driverId,
          acceptedAt: DateTime.now(),
        );
        _availableBookings.removeAt(index);
        _myBookings.insert(0, updated);
      }

      return true;
    } catch (e) {
      _setError('Failed to accept booking with chat: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Decline booking
  Future<bool> declineBooking(String bookingId, String driverId) async {
    try {
      _setLoading(true);
      _setError(null);
      await _bookingRepository.declineBooking(bookingId, driverId);
      _availableBookings.removeWhere((b) => b.id == bookingId);
      return true;
    } catch (e) {
      _setError('Failed to decline booking: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Complete a booking
  Future<bool> completeBooking(String bookingId) async {
    try {
      _setLoading(true);
      _setError(null);
      await _bookingRepository.completeBooking(bookingId);

      final index = _myBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _myBookings[index] = _myBookings[index].copyWith(
          status: BookingStatus.completed,
          completedAt: DateTime.now(),
        );
      }

      return true;
    } catch (e) {
      _setError('Failed to complete booking: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      _setLoading(true);
      _setError(null);
      await _bookingRepository.cancelBooking(bookingId);

      final index = _myBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _myBookings[index] = _myBookings[index].copyWith(
          status: BookingStatus.cancelled,
        );
      }

      return true;
    } catch (e) {
      _setError('Failed to cancel booking: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reassign booking
  Future<bool> reassignBooking(String bookingId) async {
    try {
      _setLoading(true);
      _setError(null);

      final booking = await _bookingRepository.getBookingById(bookingId);
      if (booking != null) {
        final updatedBooking = booking.copyWith(
          status: BookingStatus.pending,
          driverId: null,
        );

        await _bookingRepository.updateBooking(updatedBooking);

        final index = _myBookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _myBookings[index] = updatedBooking;
        }
      }

      return true;
    } catch (e) {
      _setError('Failed to reassign booking: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get declined bookings
  Future<List<BookingModel>> getDeclinedBookings(String cargoOwnerId) async {
    try {
      final bookings = await _bookingRepository.getBookingsByCargoOwner(cargoOwnerId);
      return bookings.where((b) => b.status == BookingStatus.declined).toList();
    } catch (e) {
      throw Exception('Failed to get declined bookings: $e');
    }
  }

  // Stream: cargo owner bookings
  Stream<List<BookingModel>> streamCargoOwnerBookings(String cargoOwnerId) {
    return _bookingRepository.getBookingsStreamByCargoOwner(cargoOwnerId);
  }

  // Stream: driver bookings
  Stream<List<BookingModel>> streamDriverBookings(String driverId) {
    return _bookingRepository.getBookingsStreamByDriver(driverId);
  }

  // Stream: available bookings for driver
  Stream<List<BookingModel>> streamAvailableBookings(String driverId) {
    return _bookingRepository.getPendingBookingsStreamForDriver(driverId);
  }
}
