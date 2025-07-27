import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../features/profile/providers/profile_provider.dart';
import '../features/cargo_owner/screens/cargo_owner_home.dart';
import '../features/driver/screens/driver_home.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final user = authProvider.user;
    debugPrint('Loading user profile. Auth user: ${user?.uid}');

    if (user != null) {
      await profileProvider.loadUserProfile(user.uid);
      debugPrint('Profile loaded for user: ${user.uid}');
    } else {
      // If no user in auth provider, try to refresh user data
      debugPrint('No user in auth provider, refreshing user data...');
      await authProvider.refreshUserData();
      final updatedUser = authProvider.user;
      if (updatedUser != null) {
        debugPrint('User data refreshed: ${updatedUser.uid}');
        await profileProvider.loadUserProfile(updatedUser.uid);
      } else {
        debugPrint('No user data available after refresh');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, authProvider, profileProvider, child) {
        // Show loading while fetching user profile
        if (profileProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your profile...'),
                ],
              ),
            ),
          );
        }

        // Handle error state
        if (profileProvider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profileProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadUserProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final userModel = profileProvider.currentUser;

        // Redirect to role-specific home screen
        if (userModel != null) {
          if (userModel.isCargoOwner) {
            return const CargoOwnerHome();
          } else if (userModel.isDriver) {
            return const DriverHome();
          }
        }

        // Fallback if user model is not loaded or role is unclear
        return const _LoadingHome();
      },
    );
  }
}

class _LoadingHome extends StatelessWidget {
  const _LoadingHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CargoLink'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your profile...'),
          ],
        ),
      ),
    );
  }
}
