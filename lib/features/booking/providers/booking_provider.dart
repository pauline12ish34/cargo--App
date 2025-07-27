import 'package:flutter/foundation.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/repositories/booking_repository.dart';
import '../../../core/enums/app_enums.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _bookingRepository;

  List<Booking> _userBookings = [];
  List<Booking> _availableBookings = [];
  Booking? _selectedBooking;
  bool _isLoading = false;
  String? _error;

  BookingProvider(this._bookingRepository);

  // Getters
  List<Booking> get userBookings => _userBookings;
  List<Booking> get availableBookings => _availableBookings;
  Booking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter bookings by status
  List<Booking> get pendingBookings =>
      _userBookings.where((b) => b.status == BookingStatus.pending).toList();

  List<Booking> get confirmedBookings =>
      _userBookings.where((b) => b.status == BookingStatus.confirmed).toList();

  List<Booking> get inProgressBookings =>
      _userBookings.where((b) => b.status == BookingStatus.inProgress).toList();

  List<Booking> get completedBookings =>
      _userBookings.where((b) => b.status == BookingStatus.completed).toList();

  // Create a new booking
  Future<String?> createBooking(Booking booking) async {
    _setLoading(true);
    _error = null;

    try {
      final bookingId = await _bookingRepository.createBooking(booking);
      await loadUserBookings(booking.cargoOwnerId, isCargoOwner: true);
      _setLoading(false);
      return bookingId;
    } catch (e) {
      _error = 'Failed to create booking: $e';
      debugPrint('Error creating booking: $e');
      _setLoading(false);
      return null;
    }
  }

  // Load user bookings (cargo owner or driver)
  Future<void> loadUserBookings(
    String userId, {
    required bool isCargoOwner,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      if (isCargoOwner) {
        _userBookings = await _bookingRepository.getBookingsByCargoOwner(
          userId,
        );
      } else {
        _userBookings = await _bookingRepository.getBookingsByDriver(userId);
      }
    } catch (e) {
      _error = 'Failed to load bookings: $e';
      debugPrint('Error loading user bookings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load available bookings for drivers
  Future<void> loadAvailableBookings() async {
    _setLoading(true);
    _error = null;

    try {
      _availableBookings = await _bookingRepository.getAvailableBookings();
    } catch (e) {
      _error = 'Failed to load available bookings: $e';
      debugPrint('Error loading available bookings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Accept a booking (driver accepting)
  Future<bool> acceptBooking(String bookingId, String driverId) async {
    _setLoading(true);
    _error = null;

    try {
      final booking = await _bookingRepository.getBookingById(bookingId);
      if (booking != null) {
        final updatedBooking = booking.copyWith(
          driverId: driverId,
          status: BookingStatus.confirmed,
          updatedAt: DateTime.now(),
        );
        await _bookingRepository.updateBooking(updatedBooking);
        await loadAvailableBookings(); // Refresh available bookings
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Failed to accept booking: $e';
      debugPrint('Error accepting booking: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final booking = await _bookingRepository.getBookingById(bookingId);
      if (booking != null) {
        final updatedBooking = booking.copyWith(
          status: status,
          updatedAt: DateTime.now(),
          deliveryDate: status == BookingStatus.completed
              ? DateTime.now()
              : null,
        );
        await _bookingRepository.updateBooking(updatedBooking);

        // Update local list
        final index = _userBookings.indexWhere((b) => b.bookingId == bookingId);
        if (index != -1) {
          _userBookings[index] = updatedBooking;
        }

        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Failed to update booking status: $e';
      debugPrint('Error updating booking status: $e');
      _setLoading(false);
      return false;
    }
  }

  // Add driver notes
  Future<bool> addDriverNotes(String bookingId, String notes) async {
    try {
      final booking = await _bookingRepository.getBookingById(bookingId);
      if (booking != null) {
        final updatedBooking = booking.copyWith(
          driverNotes: notes,
          updatedAt: DateTime.now(),
        );
        await _bookingRepository.updateBooking(updatedBooking);

        // Update local list
        final index = _userBookings.indexWhere((b) => b.bookingId == bookingId);
        if (index != -1) {
          _userBookings[index] = updatedBooking;
          notifyListeners();
        }

        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to add driver notes: $e';
      debugPrint('Error adding driver notes: $e');
      return false;
    }
  }

  // Rate a completed booking
  Future<bool> rateBooking(
    String bookingId,
    double rating,
    String? feedback,
  ) async {
    try {
      final booking = await _bookingRepository.getBookingById(bookingId);
      if (booking != null && booking.status == BookingStatus.completed) {
        final updatedBooking = booking.copyWith(
          rating: rating,
          feedback: feedback,
          updatedAt: DateTime.now(),
        );
        await _bookingRepository.updateBooking(updatedBooking);

        // Update local list
        final index = _userBookings.indexWhere((b) => b.bookingId == bookingId);
        if (index != -1) {
          _userBookings[index] = updatedBooking;
          notifyListeners();
        }

        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to rate booking: $e';
      debugPrint('Error rating booking: $e');
      return false;
    }
  }

  // Set selected booking
  void setSelectedBooking(Booking? booking) {
    _selectedBooking = booking;
    notifyListeners();
  }

  // Stream bookings for real-time updates
  void streamUserBookings(String userId, {required bool isCargoOwner}) {
    if (isCargoOwner) {
      _bookingRepository
          .bookingsStream(cargoOwnerId: userId)
          .listen(
            (bookings) {
              _userBookings = bookings;
              notifyListeners();
            },
            onError: (e) {
              _error = 'Bookings stream error: $e';
              debugPrint('Error in bookings stream: $e');
              notifyListeners();
            },
          );
    } else {
      _bookingRepository
          .bookingsStream(driverId: userId)
          .listen(
            (bookings) {
              _userBookings = bookings;
              notifyListeners();
            },
            onError: (e) {
              _error = 'Bookings stream error: $e';
              debugPrint('Error in bookings stream: $e');
              notifyListeners();
            },
          );
    }
  }

  // Clear bookings data
  void clearBookings() {
    _userBookings.clear();
    _availableBookings.clear();
    _selectedBooking = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Statistics methods
  int get totalBookings => _userBookings.length;
  int get completedBookingsCount => completedBookings.length;
  int get pendingBookingsCount => pendingBookings.length;

  double get averageRating {
    final ratedBookings = completedBookings.where((b) => b.rating != null);
    if (ratedBookings.isEmpty) return 0.0;

    final totalRating = ratedBookings.fold<double>(
      0.0,
      (sum, booking) => sum + (booking.rating ?? 0.0),
    );
    return totalRating / ratedBookings.length;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
