import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { driver, cargoOwner }

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
  final String? driverLicense;
  final String? nationalId;
  final String? vehicleRegistration;
  final String? vehicleType;
  final String? vehicleCapacity;
  final String? vehicleImageUrl;
  final bool? isAvailable;
  final double? rating;
  final int? completedJobs;

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
    this.nationalId,
    this.vehicleRegistration,
    this.vehicleType,
    this.vehicleCapacity,
    this.vehicleImageUrl,
    this.isAvailable,
    this.rating,
    this.completedJobs,
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
      nationalId: data['nationalId'],
      vehicleRegistration: data['vehicleRegistration'],
      vehicleType: data['vehicleType'],
      vehicleCapacity: data['vehicleCapacity'],
      vehicleImageUrl: data['vehicleImageUrl'],
      isAvailable: data['isAvailable'],
      rating: data['rating']?.toDouble(),
      completedJobs: data['completedJobs'],
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
      if (driverLicense != null) 'driverLicense': driverLicense,
      if (nationalId != null) 'nationalId': nationalId,
      if (vehicleRegistration != null) 'vehicleRegistration': vehicleRegistration,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (vehicleCapacity != null) 'vehicleCapacity': vehicleCapacity,
      if (vehicleImageUrl != null) 'vehicleImageUrl': vehicleImageUrl,
      if (isAvailable != null) 'isAvailable': isAvailable,
      if (rating != null) 'rating': rating,
      if (completedJobs != null) 'completedJobs': completedJobs,
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
    String? nationalId,
    String? vehicleRegistration,
    String? vehicleType,
    String? vehicleCapacity,
    String? vehicleImageUrl,
    bool? isAvailable,
    double? rating,
    int? completedJobs,
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
      nationalId: nationalId ?? this.nationalId,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleCapacity: vehicleCapacity ?? this.vehicleCapacity,
      vehicleImageUrl: vehicleImageUrl ?? this.vehicleImageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
    );
  }
}