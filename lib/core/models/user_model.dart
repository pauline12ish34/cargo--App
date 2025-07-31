import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/app_enums.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final UserRole role;
  final bool isVerified;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Driver-specific fields
  final String? driverLicense;          // Document URL - uploaded driver license file
  final String? driverLicenseNumber;    // License number text - user input (e.g., "DL123456789")
  final String? plateNumber;            // Vehicle plate number
  final String? insurance;              // Insurance document URL
  final String? nationalId;             // National ID document URL

  final String? vehicleRegistration;    // Vehicle registration document URL
  final String? vehicleType;            // Vehicle type (e.g., "Pickup Truck")
  final String? vehicleCapacity;        // Vehicle capacity (e.g., "1 ton")
  final String? vehicleImageUrl;        // Vehicle photo URL
  final bool? isAvailable;              // Driver availability status
  final double? rating;                 // Average rating
  final int? completedJobs;             // Number of completed jobs

  // Cargo Owner specific fields
  final String? companyName;
  final String? businessLicense;        // Business license document URL
  final String? companyType;

  // Address fields
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.isVerified = false,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.driverLicense,
    this.driverLicenseNumber,
    this.nationalId,
    this.vehicleRegistration,
    this.vehicleType,
    this.vehicleCapacity,
    this.vehicleImageUrl,
    this.isAvailable,
    this.rating,
    this.completedJobs,
    this.plateNumber,
    this.insurance,
    this.companyName,
    this.businessLicense,
    this.companyType,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.cargoOwner,
      ),
      isVerified: data['isVerified'] ?? false,
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      driverLicense: data['driverLicense'],
      driverLicenseNumber: data['driverLicenseNumber'],
      nationalId: data['nationalId'],
      vehicleRegistration: data['vehicleRegistration'],
      vehicleType: data['vehicleType'],
      vehicleCapacity: data['vehicleCapacity'],
      vehicleImageUrl: data['vehicleImageUrl'],
      isAvailable: data['isAvailable'],
      rating: data['rating']?.toDouble(),
      completedJobs: data['completedJobs'],
      plateNumber: data['plateNumber'],
      insurance: data['insurance'],
      companyName: data['companyName'],
      businessLicense: data['businessLicense'],
      companyType: data['companyType'],
      street: data['street'],
      city: data['city'],
      state: data['state'],
      postalCode: data['postalCode'],
      country: data['country'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
      'isVerified': isVerified,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (plateNumber != null) 'plateNumber': plateNumber,
      if (insurance != null) 'insurance': insurance,
      if (driverLicense != null) 'driverLicense': driverLicense,
      if (driverLicenseNumber != null) 'driverLicenseNumber': driverLicenseNumber,
      if (nationalId != null) 'nationalId': nationalId,
      if (vehicleRegistration != null) 'vehicleRegistration': vehicleRegistration,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (vehicleCapacity != null) 'vehicleCapacity': vehicleCapacity,
      if (vehicleImageUrl != null) 'vehicleImageUrl': vehicleImageUrl,
      if (isAvailable != null) 'isAvailable': isAvailable,
      if (rating != null) 'rating': rating,
      if (completedJobs != null) 'completedJobs': completedJobs,
      if (companyName != null) 'companyName': companyName,
      if (businessLicense != null) 'businessLicense': businessLicense,
      if (companyType != null) 'companyType': companyType,
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (postalCode != null) 'postalCode': postalCode,
      if (country != null) 'country': country,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    UserRole? role,
    bool? isVerified,
    String? profileImageUrl,
    DateTime? updatedAt,
    String? driverLicense,
    String? driverLicenseNumber,
    String? nationalId,
    String? vehicleRegistration,
    String? vehicleType,
    String? vehicleCapacity,
    String? vehicleImageUrl,
    bool? isAvailable,
    double? rating,
    int? completedJobs,
    String? plateNumber,
    String? insurance,
    String? companyName,
    String? businessLicense,
    String? companyType,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      driverLicense: driverLicense ?? this.driverLicense,
      driverLicenseNumber: driverLicenseNumber ?? this.driverLicenseNumber,
      nationalId: nationalId ?? this.nationalId,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleCapacity: vehicleCapacity ?? this.vehicleCapacity,
      vehicleImageUrl: vehicleImageUrl ?? this.vehicleImageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      plateNumber: plateNumber ?? this.plateNumber,
      insurance: insurance ?? this.insurance,
      companyName: companyName ?? this.companyName,
      businessLicense: businessLicense ?? this.businessLicense,
      companyType: companyType ?? this.companyType,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }

  // Compatibility getters for existing code
  String get firstName => name.split(' ').isNotEmpty ? name.split(' ').first : '';
  String get lastName => name.split(' ').length > 1 ? name.split(' ').sublist(1).join(' ') : '';
  String get fullName => name;
  String? get profilePictureUrl => profileImageUrl;
  bool get isDriver => role == UserRole.driver;
  bool get isCargoOwner => role == UserRole.cargoOwner;
  
  // For drivers - basic vehicle info (since we don't have the complex Vehicle model)
  Map<String, dynamic>? get primaryVehicle => vehicleType != null ? {
    'type': vehicleType,
    'capacity': vehicleCapacity,
    'registration': vehicleRegistration,
  } : null;
  
  // Mock total earnings (you might want to track this properly later)
  int get totalEarnings => (completedJobs ?? 0) * 5000; // Mock calculation
  
  // Address getter that returns actual address information
  Map<String, String>? get address {
    if (street != null || city != null || state != null || postalCode != null || country != null) {
      return {
        if (street != null) 'street': street!,
        if (city != null) 'city': city!,
        if (state != null) 'state': state!,
        if (postalCode != null) 'postalCode': postalCode!,
        if (country != null) 'country': country!,
      };
    }
    return null;
  }
  
  // Full address as a formatted string
  String get fullAddress {
    final parts = <String>[];
    if (street?.isNotEmpty == true) parts.add(street!);
    if (city?.isNotEmpty == true) parts.add(city!);
    if (state?.isNotEmpty == true) parts.add(state!);
    if (postalCode?.isNotEmpty == true) parts.add(postalCode!);
    if (country?.isNotEmpty == true) parts.add(country!);
    return parts.join(', ');
  }
}