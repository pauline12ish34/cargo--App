import '../enums/app_enums.dart';

class GeoLocation {
  final double latitude;
  final double longitude;
  final String address;

  GeoLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory GeoLocation.fromMap(Map<String, dynamic> map) {
    return GeoLocation(
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      address: map['address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude, 'address': address};
  }
}

class Booking {
  final String bookingId;
  final String cargoOwnerId;
  final String? driverId;
  final String cargoDescription;
  final double weight;
  final String dimensions;
  final GeoLocation pickupLocation;
  final GeoLocation deliveryLocation;
  final DateTime pickupDate;
  final DateTime? deliveryDate;
  final double price;
  final BookingStatus status;
  final String? specialInstructions;
  final List<String> cargoPhotos;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? driverNotes;
  final double? rating;
  final String? feedback;

  Booking({
    required this.bookingId,
    required this.cargoOwnerId,
    this.driverId,
    required this.cargoDescription,
    required this.weight,
    required this.dimensions,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupDate,
    this.deliveryDate,
    required this.price,
    required this.status,
    this.specialInstructions,
    this.cargoPhotos = const [],
    required this.createdAt,
    required this.updatedAt,
    this.driverNotes,
    this.rating,
    this.feedback,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      bookingId: map['bookingId'] ?? '',
      cargoOwnerId: map['cargoOwnerId'] ?? '',
      driverId: map['driverId'],
      cargoDescription: map['cargoDescription'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      dimensions: map['dimensions'] ?? '',
      pickupLocation: GeoLocation.fromMap(map['pickupLocation'] ?? {}),
      deliveryLocation: GeoLocation.fromMap(map['deliveryLocation'] ?? {}),
      pickupDate: DateTime.fromMillisecondsSinceEpoch(map['pickupDate']),
      deliveryDate: map['deliveryDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deliveryDate'])
          : null,
      price: (map['price'] ?? 0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${map['status']}',
        orElse: () => BookingStatus.pending,
      ),
      specialInstructions: map['specialInstructions'],
      cargoPhotos: List<String>.from(map['cargoPhotos'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      driverNotes: map['driverNotes'],
      rating: map['rating']?.toDouble(),
      feedback: map['feedback'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'cargoOwnerId': cargoOwnerId,
      'driverId': driverId,
      'cargoDescription': cargoDescription,
      'weight': weight,
      'dimensions': dimensions,
      'pickupLocation': pickupLocation.toMap(),
      'deliveryLocation': deliveryLocation.toMap(),
      'pickupDate': pickupDate.millisecondsSinceEpoch,
      'deliveryDate': deliveryDate?.millisecondsSinceEpoch,
      'price': price,
      'status': status.toString().split('.').last,
      'specialInstructions': specialInstructions,
      'cargoPhotos': cargoPhotos,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'driverNotes': driverNotes,
      'rating': rating,
      'feedback': feedback,
    };
  }

  Booking copyWith({
    String? bookingId,
    String? cargoOwnerId,
    String? driverId,
    String? cargoDescription,
    double? weight,
    String? dimensions,
    GeoLocation? pickupLocation,
    GeoLocation? deliveryLocation,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    double? price,
    BookingStatus? status,
    String? specialInstructions,
    List<String>? cargoPhotos,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? driverNotes,
    double? rating,
    String? feedback,
  }) {
    return Booking(
      bookingId: bookingId ?? this.bookingId,
      cargoOwnerId: cargoOwnerId ?? this.cargoOwnerId,
      driverId: driverId ?? this.driverId,
      cargoDescription: cargoDescription ?? this.cargoDescription,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      price: price ?? this.price,
      status: status ?? this.status,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      cargoPhotos: cargoPhotos ?? this.cargoPhotos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      driverNotes: driverNotes ?? this.driverNotes,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
    );
  }
}
