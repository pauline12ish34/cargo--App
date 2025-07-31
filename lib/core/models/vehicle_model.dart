import '../enums/app_enums.dart';

class Vehicle {
  final String vehicleId;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final VehicleType type;
  final VehicleCapacity capacity;
  final double maxWeight;
  final String registrationNumber;
  final DateTime? registrationExpiry;
  final DateTime? insuranceExpiry;
  final List<String> photos;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.vehicleId,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.type,
    required this.capacity,
    required this.maxWeight,
    required this.registrationNumber,
    this.registrationExpiry,
    this.insuranceExpiry,
    this.photos = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      vehicleId: map['vehicleId'] ?? '',
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 0,
      licensePlate: map['licensePlate'] ?? '',
      type: VehicleType.values.firstWhere(
        (e) => e.toString() == 'VehicleType.${map['type']}',
        orElse: () => VehicleType.truck,
      ),
      capacity: VehicleCapacity.values.firstWhere(
        (e) => e.toString() == 'VehicleCapacity.${map['capacity']}',
        orElse: () => VehicleCapacity.medium,
      ),
      maxWeight: (map['maxWeight'] ?? 0).toDouble(),
      registrationNumber: map['registrationNumber'] ?? '',
      registrationExpiry: map['registrationExpiry'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['registrationExpiry'])
          : null,
      insuranceExpiry: map['insuranceExpiry'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['insuranceExpiry'])
          : null,
      photos: List<String>.from(map['photos'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'make': make,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'type': type.toString().split('.').last,
      'capacity': capacity.toString().split('.').last,
      'maxWeight': maxWeight,
      'registrationNumber': registrationNumber,
      'registrationExpiry': registrationExpiry?.millisecondsSinceEpoch,
      'insuranceExpiry': insuranceExpiry?.millisecondsSinceEpoch,
      'photos': photos,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  Vehicle copyWith({
    String? vehicleId,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    VehicleType? type,
    VehicleCapacity? capacity,
    double? maxWeight,
    String? registrationNumber,
    DateTime? registrationExpiry,
    DateTime? insuranceExpiry,
    List<String>? photos,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      vehicleId: vehicleId ?? this.vehicleId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      maxWeight: maxWeight ?? this.maxWeight,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      registrationExpiry: registrationExpiry ?? this.registrationExpiry,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      photos: photos ?? this.photos,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
