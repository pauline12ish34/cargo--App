import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Initialize auth state
  Future<void> initializeAuth() async {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        try {
          _user = await _authService.getCurrentUserData();
        } catch (e) {
          _error = e.toString();
        }
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required UserRole role,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
      );
      
      return true;
    } catch (e) {
      _setError('Registration error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign up anonymously for testing
  Future<bool> signUpAnonymously({
    required String name,
    required String phoneNumber,
    required UserRole role,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final credential = await FirebaseAuth.instance.signInAnonymously();
      
      if (credential.user != null) {
        final userModel = UserModel(
          uid: credential.user!.uid,
          name: name,
          email: 'anonymous@test.com',
          phoneNumber: phoneNumber,
          role: role,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isAvailable: role == UserRole.driver ? false : null,
          rating: role == UserRole.driver ? 0.0 : null,
          completedJobs: role == UserRole.driver ? 0 : null,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toFirestore());
        
        _user = userModel;
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = _authService.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if email is verified
  Future<void> checkEmailVerification() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        await user.reload();
        _user = await _authService.getCurrentUserData();
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.updateUserProfile(
        name: name,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );
      
      // Refresh user data
      _user = await _authService.getCurrentUserData();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update driver documents
  Future<bool> updateDriverDocuments({
    required String driverLicense,
    required String nationalId,
    required String vehicleRegistration,
    required String vehicleType,
    required String vehicleCapacity,
    String? vehicleImageUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.updateDriverDocuments(
        driverLicense: driverLicense,
        nationalId: nationalId,
        vehicleRegistration: vehicleRegistration,
        vehicleType: vehicleType,
        vehicleCapacity: vehicleCapacity,
        vehicleImageUrl: vehicleImageUrl,
      );
      
      // Refresh user data
      _user = await _authService.getCurrentUserData();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update driver availability
  Future<bool> updateDriverAvailability(bool isAvailable) async {
    try {
      await _authService.updateDriverAvailability(isAvailable);
      
      // Update local user data
      if (_user != null && _user!.role == UserRole.driver) {
        _user = _user!.copyWith(isAvailable: isAvailable);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}