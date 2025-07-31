import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/enums/app_enums.dart';
import '../../profile/providers/profile_provider.dart';
import '../../booking/providers/booking_provider.dart';
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
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    final user = profileProvider.currentUser;
    if (user != null) {
      bookingProvider.loadUserBookings(user.uid, isCargoOwner: false);
      bookingProvider.loadAvailableBookings();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _DriverHomeTab(),
          _DriverJobsTab(),
          _DriverHistoryTab(),
          _DriverProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DriverHomeTab extends StatelessWidget {
  const _DriverHomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileProvider, BookingProvider>(
      builder: (context, profileProvider, bookingProvider, child) {
        final user = profileProvider.currentUser;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Top Bar
                AppTopBar(user: user),

                // Content
                Expanded(
                  child: Padding(
                    padding: defaultPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Stats Cards
                        Row(
                          children: [
                            Expanded(
                              child: StatsCard(
                                title: 'Active Jobs',
                                value: bookingProvider.confirmedBookings.length
                                    .toString(),
                                icon: Icons.local_shipping,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatsCard(
                                title: 'Completed',
                                value: bookingProvider.completedBookingsCount
                                    .toString(),
                                icon: Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: StatsCard(
                                title: 'Available Jobs',
                                value: bookingProvider.availableBookings.length
                                    .toString(),
                                icon: Icons.work,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatsCard(
                                title: 'Rating',
                                value: (user?.rating ?? 0.0).toStringAsFixed(1),
                                icon: Icons.star,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Active Jobs Section
                        Text(
                          'Active Jobs',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        Expanded(
                          child: bookingProvider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : bookingProvider.confirmedBookings.isEmpty &&
                                    bookingProvider.inProgressBookings.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.work_off,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text('No active jobs'),
                                      Text(
                                        'Check the Jobs tab for available work',
                                      ),
                                    ],
                                  ),
                                )
                              : ListView(
                                  children: [
                                    ...bookingProvider.inProgressBookings.map(
                                      (booking) => _BookingListItem(
                                        booking: booking,
                                        isDriver: true,
                                      ),
                                    ),
                                    ...bookingProvider.confirmedBookings.map(
                                      (booking) => _BookingListItem(
                                        booking: booking,
                                        isDriver: true,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DriverJobsTab extends StatelessWidget {
  const _DriverJobsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer2<ProfileProvider, BookingProvider>(
          builder: (context, profileProvider, bookingProvider, child) {
            final user = profileProvider.currentUser;

            return Column(
              children: [
                // Top Bar
                AppTopBar(user: user),

                // Content
                Expanded(
                  child: bookingProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : bookingProvider.availableBookings.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.work_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text('No available jobs'),
                              Text('Check back later for new opportunities'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: defaultPadding,
                          itemCount: bookingProvider.availableBookings.length,
                          itemBuilder: (context, index) {
                            final booking =
                                bookingProvider.availableBookings[index];
                            return _AvailableJobCard(booking: booking);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DriverHistoryTab extends StatelessWidget {
  const _DriverHistoryTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer2<ProfileProvider, BookingProvider>(
          builder: (context, profileProvider, bookingProvider, child) {
            final user = profileProvider.currentUser;
            final completedBookings = bookingProvider.completedBookings;

            return Column(
              children: [
                // Top Bar
                AppTopBar(user: user),

                // Content
                Expanded(
                  child: completedBookings.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No completed jobs yet'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: defaultPadding,
                          itemCount: completedBookings.length,
                          itemBuilder: (context, index) {
                            final booking = completedBookings[index];
                            return _BookingListItem(
                              booking: booking,
                              isDriver: true,
                              showRating: true,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DriverProfileTab extends StatefulWidget {
  const _DriverProfileTab();

  @override
  State<_DriverProfileTab> createState() => _DriverProfileTabState();
}

class _DriverProfileTabState extends State<_DriverProfileTab>
    with ImagePickerMixin, LogoutMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final user = profileProvider.currentUser;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Profile Header
              ProfileHeader(
                user: user,
                onImageTap: () => showImagePickerDialog(context),
              ),

              // Profile Options
              Expanded(child: _buildProfileOptions(context, user)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            user.fullName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            user.email,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),

          // Driver Stats
          Consumer<BookingProvider>(
            builder: (context, bookingProvider, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ProfileStat(
                    label: 'Jobs Completed',
                    value: bookingProvider.completedBookingsCount.toString(),
                  ),
                  _ProfileStat(
                    label: 'Rating',
                    value: (user.rating ?? 0.0).toStringAsFixed(1),
                  ),
                  _ProfileStat(
                    label: 'Total Earnings',
                    value: '\$${user.totalEarnings}',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

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
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();

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
                            await Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).signOut();

                            // Clear profile data
                            Provider.of<ProfileProvider>(
                              context,
                              listen: false,
                            ).logout();

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
                              Navigator.of(
                                context,
                              ).pop(); // Hide loading dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Logout failed: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// Helper Widgets

class _BookingListItem extends StatelessWidget {
  final Booking booking;
  final bool isDriver;
  final bool showRating;

  const _BookingListItem({
    required this.booking,
    this.isDriver = false,
    this.showRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(),
          child: Icon(_getStatusIcon(), color: Colors.white),
        ),
        title: Text(
          booking.cargoDescription,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${booking.pickupLocation.address} → ${booking.deliveryLocation.address}',
            ),
            Text('\$${booking.price.toStringAsFixed(2)}'),
            if (showRating && booking.rating != null)
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(booking.rating!.toStringAsFixed(1)),
                ],
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(
                booking.status.toString().split('.').last.toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: _getStatusColor().withOpacity(0.1),
              side: BorderSide(color: _getStatusColor()),
            ),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job Details - Coming Soon!')),
          );
        },
      ),
    );
  }

  Color _getStatusColor() {
    switch (booking.status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (booking.status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.confirmed:
        return Icons.check;
      case BookingStatus.inProgress:
        return Icons.local_shipping;
      case BookingStatus.completed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }
}

class _AvailableJobCard extends StatelessWidget {
  final Booking booking;

  const _AvailableJobCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '\$${booking.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.pickupLocation.address,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.location_off, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.deliveryLocation.address,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Pickup: ${booking.pickupDate.day}/${booking.pickupDate.month}/${booking.pickupDate.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (booking.specialInstructions?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'Special Instructions: ${booking.specialInstructions}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showAcceptJobDialog(context, booking);
                },
                child: const Text('Accept Job'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptJobDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accept Job'),
          content: Text(
            'Do you want to accept this cargo delivery job?\n\nCargo: ${booking.cargoDescription}\nPrice: \$${booking.price.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _acceptJob(context, booking);
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  void _acceptJob(BuildContext context, Booking booking) async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    final user = profileProvider.currentUser;
    if (user != null) {
      final success = await bookingProvider.acceptBooking(
        booking.bookingId,
        user.uid,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bookingProvider.error ?? 'Failed to accept job'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
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
