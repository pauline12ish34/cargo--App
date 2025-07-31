import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/models/user_model.dart';
import '../../../features/booking/providers/booking_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/profile_header.dart';
import '../../../widgets/stats_card.dart';
import '../../../widgets/app_top_bar.dart';
import '../../../mixins/image_picker_mixin.dart';
import '../../../mixins/logout_mixin.dart';
import '../../../constants.dart';
import '../../../screens/driver_profile_edit_screen.dart';
import '../../../screens/vehicle_details_screen.dart';
import '../../../screens/settings_screen.dart';
import '../../../screens/help_support_screen.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../screens/job_details_screen.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    if (authProvider.user != null) {
      bookingProvider.loadDriverBookings(authProvider.user!.uid);
      bookingProvider.loadAvailableBookings(authProvider.user!.uid);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _DashboardTab(onNavigateToTab: _onItemTapped),
      const _AvailableJobsTab(),
      const _MyJobsTab(),
      const _ProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: 'PaytoneOne',
            ),
            children: [
              const TextSpan(
                text: 'Cargo',
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: 'Link',
                style: TextStyle(color: primaryGreen),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final isAvailable = authProvider.user?.isAvailable ?? false;
              return Switch(
                value: isAvailable,
                onChanged: (value) async {
                  await authProvider.updateDriverAvailability(value);
                },
                activeColor: Colors.white,
                activeTrackColor: primaryGreen,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Available',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'My Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryGreen,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const _DashboardTab({required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, BookingProvider>(
      builder: (context, authProvider, bookingProvider, child) {
        final user = authProvider.user;
        final myJobs = bookingProvider.myBookings;
        final availableJobs = bookingProvider.availableBookings;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryGreen, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${user?.name ?? 'Driver'}!',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user?.isAvailable == true
                                    ? 'You are available for jobs'
                                    : 'Set yourself as available to receive job requests',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: user?.isAvailable == true
                                ? primaryGreen
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user?.isAvailable == true ? 'AVAILABLE' : 'OFFLINE',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Jobs',
                      value: '${user?.completedJobs ?? 0}',
                      icon: Icons.work,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Rating',
                      value: '${user?.rating?.toStringAsFixed(1) ?? '0.0'}',
                      icon: Icons.star,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Available Jobs',
                      value: '${availableJobs.length}',
                      icon: Icons.assignment,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Active Jobs',
                      value: '${myJobs.where((j) => j.status == BookingStatus.accepted || j.status == BookingStatus.inProgress).length}',
                      icon: Icons.local_shipping,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Available Jobs
              if (user?.isAvailable == true) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Jobs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onNavigateToTab(1),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (bookingProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (availableJobs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.work_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No available jobs',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Check back later for new opportunities',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...availableJobs.take(3).map((job) => _AvailableJobCard(booking: job)),
              ],

              // Recent My Jobs
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Recent Jobs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateToTab(2),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (myJobs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No jobs yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Accept available jobs to get started',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...myJobs.take(3).map((job) => _MyJobCard(booking: job)),
            ],
          ),
        );
      },
    );
  }
}

class _AvailableJobsTab extends StatelessWidget {
  const _AvailableJobsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, BookingProvider>(
      builder: (context, authProvider, bookingProvider, child) {
        if (authProvider.user?.isAvailable == false) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.toggle_off,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'You are currently offline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Turn on availability to see job requests',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (bookingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bookingProvider.availableBookings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.work_off,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No available jobs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Check back later for new opportunities',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (authProvider.user != null) {
              await bookingProvider.loadAvailableBookings(authProvider.user!.uid);
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookingProvider.availableBookings.length,
            itemBuilder: (context, index) {
              final booking = bookingProvider.availableBookings[index];
              return _AvailableJobCard(booking: booking);
            },
          ),
        );
      },
    );
  }
}

class _MyJobsTab extends StatelessWidget {
  const _MyJobsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bookingProvider.myBookings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No jobs yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Accept available jobs to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            if (authProvider.user != null) {
              await bookingProvider.loadDriverBookings(authProvider.user!.uid);
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookingProvider.myBookings.length,
            itemBuilder: (context, index) {
              final booking = bookingProvider.myBookings[index];
              return _MyJobCard(booking: booking);
            },
          ),
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, authProvider, profileProvider, child) {
        final user = profileProvider.currentUser ?? authProvider.user;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: primaryGreen,
                      child: Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : 'D',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'Driver',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Driver',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: user?.isAvailable == true
                                ? primaryGreen
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user?.isAvailable == true ? 'Available' : 'Offline',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${user?.rating?.toStringAsFixed(1) ?? '0.0'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Rating',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${user?.completedJobs ?? 0}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Jobs Done',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Profile Options
              _ProfileOption(
                icon: Icons.edit,
                title: 'Edit Profile',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DriverProfileEditScreen(),
                    ),
                  );
                },
              ),
              if (user != null) ...[
                _ProfileOption(
                  icon: Icons.card_membership,
                  title: 'Driver License',
                  subtitle: user.driverLicense ?? 'Add license details',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DriverProfileEditScreen(),
                      ),
                    );
                  },
                ),
                _ProfileOption(
                  icon: Icons.directions_car,
                  title: 'Vehicle Details',
                  subtitle: user.primaryVehicle != null
                      ? '${user.primaryVehicle!['type']} - ${user.primaryVehicle!['capacity']}'
                      : 'Add vehicle details',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const VehicleDetailsScreen(),
                      ),
                    );
                  },
                ),
                _ProfileOption(
                  icon: Icons.location_on,
                  title: 'Address',
                  subtitle: user.fullAddress.isNotEmpty
                      ? user.fullAddress
                      : 'Add your address',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DriverProfileEditScreen(),
                      ),
                    );
                  },
                ),
              ],
              _ProfileOption(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              _ProfileOption(
                icon: Icons.help,
                title: 'Help & Support',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),
              _ProfileOption(
                icon: Icons.logout,
                title: 'Logout',
                isDestructive: true,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Logging out...'),
            ],
          ),
        );
      },
    );

    try {
      // Perform logout
      await Provider.of<AuthProvider>(context, listen: false).signOut();

      // Clear profile data
      Provider.of<ProfileProvider>(context, listen: false).logout();

      // Navigate to login screen and clear navigation stack
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      // Hide loading dialog and show error
      if (context.mounted) {
        Navigator.of(context).pop(); // Hide loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableJobCard extends StatelessWidget {
  final BookingModel booking;

  const _AvailableJobCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.cargoDescription,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (booking.estimatedPrice != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${booking.estimatedPrice!.toStringAsFixed(0)} RWF',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'From: ${booking.pickupLocation}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.flag, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'To: ${booking.dropoffLocation}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.local_shipping, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  booking.vehicleTypeDisplayName,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (booking.weight != null) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.scale, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.weight}kg',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
                const Spacer(),
                Text(
                  _getTimeAgo(booking.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if (booking.specialInstructions?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'Special instructions: ${booking.specialInstructions}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _declineJob(context, booking),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptJob(context, booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _acceptJob(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Job'),
        content: const Text('Are you sure you want to accept this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

              if (authProvider.user != null) {
                final success = await bookingProvider.acceptBooking(
                  booking.id,
                  authProvider.user!.uid,
                );

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Job accepted successfully!'),
                      backgroundColor: primaryGreen,
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(bookingProvider.error ?? 'Failed to accept job'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _declineJob(BuildContext context, BookingModel booking) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    if (authProvider.user != null) {
      bookingProvider.declineBooking(booking.id, authProvider.user!.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job declined'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _MyJobCard extends StatelessWidget {
  final BookingModel booking;

  const _MyJobCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (booking.status) {
      case BookingStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case BookingStatus.accepted:
        statusColor = primaryGreen;
        statusIcon = Icons.check_circle;
        break;
      case BookingStatus.inProgress:
        statusColor = Colors.purple;
        statusIcon = Icons.local_shipping;
        break;
      case BookingStatus.completed:
        statusColor = Colors.black;
        statusIcon = Icons.check_circle_outline;
        break;
      case BookingStatus.declined:
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailsScreen(booking: booking),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.cargoDescription,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          booking.statusDisplayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'From: ${booking.pickupLocation}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.flag, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'To: ${booking.dropoffLocation}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_shipping, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    booking.vehicleTypeDisplayName,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (booking.weight != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.scale, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.weight}kg',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              if (booking.finalPrice != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.money, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Payment: ${booking.finalPrice!.toStringAsFixed(0)} RWF',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],

              // Show action indicator for accepted jobs
              if (booking.status == BookingStatus.accepted) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryGreen),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat, size: 16, color: primaryGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tap to chat with cargo owner or mark as completed',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileOption({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : null),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : null),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}