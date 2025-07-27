import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/firebase_auth_helper.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService() {
    // Configure Firebase Auth settings for better debugging
    _auth.setLanguageCode('en');
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required UserRole role,
  }) async {
    try {
      print('Attempting to create user with email: $email');

      // Create auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User created successfully, creating Firestore document...');

      // Create user document in Firestore
      if (credential.user != null) {
        final userModel = UserModel(
          uid: credential.user!.uid,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          role: role,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          // Initialize driver-specific fields if role is driver
          isAvailable: role == UserRole.driver ? false : null,
          rating: role == UserRole.driver ? 0.0 : null,
          completedJobs: role == UserRole.driver ? 0 : null,
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toFirestore());

        // Update display name
        await credential.user!.updateDisplayName(name);

        print('User profile created successfully');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth error: ${e.code} - ${e.message}');
      throw _getAuthException(e);
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final user = currentUser;
      if (user != null) {
        final updates = <String, dynamic>{
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        };

        if (name != null) {
          updates['name'] = name;
          await user.updateDisplayName(name);
        }
        if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
        if (profileImageUrl != null) {
          updates['profileImageUrl'] = profileImageUrl;
        }

        await _firestore.collection('users').doc(user.uid).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Update driver verification documents
  Future<void> updateDriverDocuments({
    required String driverLicense,
    required String nationalId,
    required String vehicleRegistration,
    required String vehicleType,
    required String vehicleCapacity,
    String? vehicleImageUrl,
  }) async {
    try {
      final user = currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'driverLicense': driverLicense,
          'nationalId': nationalId,
          'vehicleRegistration': vehicleRegistration,
          'vehicleType': vehicleType,
          'vehicleCapacity': vehicleCapacity,
          'vehicleImageUrl': vehicleImageUrl,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      throw Exception('Failed to update driver documents: $e');
    }
  }

  // Update driver availability
  Future<void> updateDriverAvailability(bool isAvailable) async {
    try {
      final user = currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'isAvailable': isAvailable,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      throw Exception('Failed to update availability: $e');
    }
  }

  // Helper method to convert FirebaseAuthException to user-friendly messages
  String _getAuthException(FirebaseAuthException e) {
    return FirebaseAuthHelper.getAuthErrorMessage(e);
  }
}
