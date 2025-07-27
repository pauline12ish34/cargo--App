import 'package:flutter/foundation.dart';
import '../../../core/models/user_model.dart';
import '../../../core/repositories/user_repository.dart';
import '../../../core/enums/app_enums.dart';

class ProfileProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  ProfileProvider(this._userRepository);

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDriver => _currentUser?.role == UserRole.driver;
  bool get isCargoOwner => _currentUser?.role == UserRole.cargoOwner;
  bool get hasCompleteProfile => _currentUser != null && _isProfileComplete();

  // Set current user
  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    _error = null;
    notifyListeners();
  }

  // Load user profile
  Future<void> loadUserProfile(String uid) async {
    _setLoading(true);
    _error = null;

    try {
      debugPrint('Loading user profile for UID: $uid');
      final user = await _userRepository.getUserById(uid);
      _currentUser = user;
      debugPrint('User profile loaded: ${user?.name} (${user?.role})');
    } catch (e) {
      _error = 'Failed to load profile: $e';
      debugPrint('Error loading user profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    _error = null;

    try {
      await _userRepository.updateUser(updatedUser);
      _currentUser = updatedUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      debugPrint('Error updating user profile: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update specific fields
  Future<bool> updateProfileField({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    String? driverLicense,
    String? nationalId,
    String? vehicleRegistration,
    String? vehicleType,
    String? vehicleCapacity,
    String? vehicleImageUrl,
    bool? isAvailable,
    bool? isVerified,
    String? companyName,
    String? businessLicense,
    String? companyType,
  }) async {
    if (_currentUser == null) return false;

    final updatedUser = _currentUser!.copyWith(
      name: name,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
      driverLicense: driverLicense,
      nationalId: nationalId,
      vehicleRegistration: vehicleRegistration,
      vehicleType: vehicleType,
      vehicleCapacity: vehicleCapacity,
      vehicleImageUrl: vehicleImageUrl,
      isAvailable: isAvailable,
      isVerified: isVerified,
      companyName: companyName,
      businessLicense: businessLicense,
      companyType: companyType,
      updatedAt: DateTime.now(),
    );

    return await updateProfile(updatedUser);
  }

  // Stream user profile changes
  void streamUserProfile(String uid) {
    _userRepository
        .userStream(uid)
        .listen(
          (user) {
            if (user != null) {
              _currentUser = user;
              notifyListeners();
            }
          },
          onError: (e) {
            _error = 'Profile stream error: $e';
            debugPrint('Error in user profile stream: $e');
            notifyListeners();
          },
        );
  }

  // Check if profile is complete
  bool _isProfileComplete() {
    if (_currentUser == null) return false;

    final user = _currentUser!;

    // Basic fields required for all users
    final basicComplete =
        user.name.isNotEmpty &&
        user.phoneNumber.isNotEmpty &&
        user.email.isNotEmpty;

    if (!basicComplete) return false;

    // For new users, basic completion is sufficient to show the home screen
    // Role-specific verification can be done later through profile completion
    return true;
  }

  // Check if profile is fully verified (for advanced features)
  bool isProfileFullyVerified() {
    if (_currentUser == null) return false;

    final user = _currentUser!;

    // Basic fields required for all users
    final basicComplete =
        user.name.isNotEmpty &&
        user.phoneNumber.isNotEmpty &&
        user.email.isNotEmpty;

    if (!basicComplete) return false;

    // Role-specific verification checks
    if (user.role == UserRole.driver) {
      return user.driverLicense?.isNotEmpty == true &&
          user.nationalId?.isNotEmpty == true &&
          user.vehicleRegistration?.isNotEmpty == true &&
          user.vehicleType?.isNotEmpty == true &&
          user.vehicleCapacity?.isNotEmpty == true;
    } else if (user.role == UserRole.cargoOwner) {
      // For cargo owners, basic completion is sufficient
      // Company fields are optional for individual users
      return true;
    }

    return true;
  }

  // Get completion percentage
  double getProfileCompletionPercentage() {
    if (_currentUser == null) return 0.0;

    final user = _currentUser!;
    int completed = 0;
    int total = 0;

    // Basic fields (required for all)
    total += 3; // name, email, phoneNumber
    if (user.name.isNotEmpty) completed++;
    if (user.email.isNotEmpty) completed++;
    if (user.phoneNumber.isNotEmpty) completed++;

    // Optional basic fields
    total += 1; // profileImageUrl
    if (user.profileImageUrl?.isNotEmpty == true) completed++;

    // Role-specific fields
    if (user.role == UserRole.driver) {
      total +=
          5; // driverLicense, nationalId, vehicleRegistration, vehicleType, vehicleCapacity
      if (user.driverLicense?.isNotEmpty == true) completed++;
      if (user.nationalId?.isNotEmpty == true) completed++;
      if (user.vehicleRegistration?.isNotEmpty == true) completed++;
      if (user.vehicleType?.isNotEmpty == true) completed++;
      if (user.vehicleCapacity?.isNotEmpty == true) completed++;
    } else if (user.role == UserRole.cargoOwner) {
      total += 3; // companyName, businessLicense, companyType (optional)
      if (user.companyName?.isNotEmpty == true) completed++;
      if (user.businessLicense?.isNotEmpty == true) completed++;
      if (user.companyType?.isNotEmpty == true) completed++;
    }

    return total > 0 ? completed / total : 0.0;
  }

  // Clear profile data
  void clearProfile() {
    _currentUser = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
