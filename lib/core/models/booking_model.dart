import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  accepted,
  declined,
  inProgress,
  completed,
  cancelled
}

enum VehicleType {
  miniTruck,
  pickup,
  largeTruck,
  van,
  motorcycle
}

class BookingModel {
  final String id;
  final String cargoOwnerId;
  final String? driverId;
  final String pickupLocation;
  final String dropoffLocation;
  final String cargoDescription;
  final VehicleType vehicleType;
  final double? weight;
  final String? specialInstructions;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final double? estimatedPrice;
  final double? finalPrice;
  final String? notes;

  const BookingModel({
    required this.id,
    required this.cargoOwnerId,
    this.driverId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.cargoDescription,
    required this.vehicleType,
    this.weight,
    this.specialInstructions,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.estimatedPrice,
    this.finalPrice,
    this.notes,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BookingModel(
      id: doc.id,
      cargoOwnerId: data['cargoOwnerId'] ?? '',
      driverId: data['driverId'],
      pickupLocation: data['pickupLocation'] ?? '',
      dropoffLocation: data['dropoffLocation'] ?? '',
      cargoDescription: data['cargoDescription'] ?? '',
      vehicleType: VehicleType.values.firstWhere(
            (e) => e.toString().split('.').last == data['vehicleType'],
        orElse: () => VehicleType.miniTruck,
      ),
      weight: data['weight']?.toDouble(),
      specialInstructions: data['specialInstructions'],
      status: BookingStatus.values.firstWhere(
            (e) => e.toString().split('.').last == data['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      acceptedAt: data['acceptedAt'] != null
          ? (data['acceptedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      estimatedPrice: data['estimatedPrice']?.toDouble(),
      finalPrice: data['finalPrice']?.toDouble(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cargoOwnerId': cargoOwnerId,
      'driverId': driverId,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'cargoDescription': cargoDescription,
      'vehicleType': vehicleType.toString().split('.').last,
      'weight': weight,
      'specialInstructions': specialInstructions,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'estimatedPrice': estimatedPrice,
      'finalPrice': finalPrice,
      'notes': notes,
    };
  }

  BookingModel copyWith({
    String? id,
    String? cargoOwnerId,
    String? driverId,
    String? pickupLocation,
    String? dropoffLocation,
    String? cargoDescription,
    VehicleType? vehicleType,
    double? weight,
    String? specialInstructions,
    BookingStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    double? estimatedPrice,
    double? finalPrice,
    String? notes,
  }) {
    return BookingModel(
      id: id ?? this.id,
      cargoOwnerId: cargoOwnerId ?? this.cargoOwnerId,
      driverId: driverId ?? this.driverId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      cargoDescription: cargoDescription ?? this.cargoDescription,
      vehicleType: vehicleType ?? this.vehicleType,
      weight: weight ?? this.weight,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      notes: notes ?? this.notes,
    );
  }

  String get vehicleTypeDisplayName {
    switch (vehicleType) {
      case VehicleType.miniTruck:
        return 'Mini Truck';
      case VehicleType.pickup:
        return 'Pickup';
      case VehicleType.largeTruck:
        return 'Large Truck';
      case VehicleType.van:
        return 'Van';
      case VehicleType.motorcycle:
        return 'Motorcycle';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.declined:
        return 'Declined';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}