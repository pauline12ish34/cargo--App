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
  final String? driverLicense;
  final String? nationalId;
  final String? vehicleRegistration;
  final String? vehicleType;
  final String? vehicleCapacity;
  final String? vehicleImageUrl;
  final bool? isAvailable;
  final double? rating;
  final int? completedJobs;

  // Cargo Owner specific fields
  final String? companyName;
  final String? businessLicense;
  final String? companyType;

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
    this.companyName,
    this.businessLicense,
    this.companyType,
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
      companyName: data['companyName'],
      businessLicense: data['businessLicense'],
      companyType: data['companyType'],
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
      if (companyName != null) 'companyName': companyName,
      if (businessLicense != null) 'businessLicense': businessLicense,
      if (companyType != null) 'companyType': companyType,
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
    String? companyName,
    String? businessLicense,
    String? companyType,
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
      companyName: companyName ?? this.companyName,
      businessLicense: businessLicense ?? this.businessLicense,
      companyType: companyType ?? this.companyType,
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
  
  // Mock address (you might want to add proper address support later)
  Map<String, String>? get address => null;
}
