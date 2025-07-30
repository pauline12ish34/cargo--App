import 'package:cargo_app/screens/car_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../core/models/booking_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/enums/app_enums.dart';
import '../../profile/providers/profile_provider.dart';
import '../../booking/providers/booking_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/profile_header.dart';
import '../../../widgets/app_top_bar.dart';
import '../../../widgets/search_bar.dart';
import '../../../widgets/vehicle_card.dart';
import '../../../widgets/stats_card.dart';
import '../../../mixins/image_picker_mixin.dart';
import '../../../mixins/logout_mixin.dart';
import '../../../constants.dart';

class CargoOwnerHome extends StatefulWidget {
  const CargoOwnerHome({super.key});

  @override
  State<CargoOwnerHome> createState() => _CargoOwnerHomeState();
}

class _CargoOwnerHomeState extends State<CargoOwnerHome> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  void _loadBookings() {
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
      bookingProvider.loadUserBookings(user.uid, isCargoOwner: true);
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
          _CargoOwnerHomeTab(),
          _CargoOwnerBookingsTab(),
          _CargoOwnerHistoryTab(),
          _CargoOwnerProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF08914D),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _CargoOwnerHomeTab extends StatelessWidget {
  const _CargoOwnerHomeTab();

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

                // Search Bar
                const AppSearchBar(),

                // Promotional Banner
                _buildPromotionalBanner(context),

                // Available Vehicles Section
                Expanded(child: _buildAvailableVehiclesSection(context)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromotionalBanner(BuildContext context) {
    return Container(
      margin: defaultMargin,
      height: 160,
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        image: const DecorationImage(
          image: AssetImage('assets/images/welcome.png'),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Container(
        padding: defaultPadding,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Book A Truck For Your Cargo\nQuickly And Easier!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to booking creation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create Booking - Coming Soon!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonBorderRadius),
                ),
              ),
              child: const Text('VIEW MORE'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableVehiclesSection(BuildContext context) {
    return Column(
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Available Cars',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to see all vehicles
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: appGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Available Vehicles List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              VehicleCard(
                address: 'Nyarutarama',
                details: 'Automatic | 5 tons | 80K RWF',
                distance: '800m (5mins away)',
                status: 'Available',
                onViewDetails: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RideDetailsPage()),
                  );

                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     content: Text('Vehicle Details - Coming Soon!'),
                  //   ),
                  // );
                },
              ),
              VehicleCard(
                address: 'Kimironko',
                details: 'Automatic | 5 tons | 80K RWF',
                distance: '800m (5mins away)',
                status: 'Available',
                onViewDetails: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RideDetailsPage()),
                  );
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     content: Text('Vehicle Details - Coming Soon!'),
                  //   ),
                  // );
                },
              ),
              VehicleCard(
                address: 'Nyarutarama',
                details: 'Automatic | 5 tons | 80K RWF',
                distance: '800m (5mins away)',
                status: 'Available',
                onViewDetails: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RideDetailsPage()),
                  );
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     content: Text('Vehicle Details - Coming Soon!'),
                  //   ),
                  // );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CargoOwnerBookingsTab extends StatefulWidget {
  const _CargoOwnerBookingsTab();

  @override
  State<_CargoOwnerBookingsTab> createState() => _CargoOwnerBookingsTabState();
}

class _CargoOwnerBookingsTabState extends State<_CargoOwnerBookingsTab> {
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            final user = profileProvider.currentUser;

            return Column(
              children: [
                // Top Bar
                AppTopBar(user: user),

                // Search Bar
                const AppSearchBar(),

                // Filter Tabs
                _buildFilterTabs(),

                // Bookings List
                Expanded(child: _buildBookingsList()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: defaultMargin,
      child: Row(
        children: [
          Expanded(child: _buildFilterTab('Upcoming', 0)),
          const SizedBox(width: 8),
          Expanded(child: _buildFilterTab('Completed', 1)),
          const SizedBox(width: 8),
          Expanded(child: _buildFilterTab('Cancelled', 2)),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, int index) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? appGreen : searchBg,
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : appGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bookingProvider.userBookings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No bookings yet'),
                Text('Create your first booking to get started'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3, // Show 3 sample bookings
          itemBuilder: (context, index) {
            final addresses = ['Kimironko', 'Nyarutarama', 'Nyarutarama'];
            return VehicleCard(
              address: addresses[index],
              details: 'Automatic | 5 tons | 80K RWF',
              distance: '800m (5mins away)',
              status: 'Booked',
            );
          },
        );
      },
    );
  }
}

class _CargoOwnerHistoryTab extends StatelessWidget {
  const _CargoOwnerHistoryTab();

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
                              Text('No completed bookings yet'),
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

class _CargoOwnerProfileTab extends StatefulWidget {
  const _CargoOwnerProfileTab();

  @override
  State<_CargoOwnerProfileTab> createState() => _CargoOwnerProfileTabState();
}

class _CargoOwnerProfileTabState extends State<_CargoOwnerProfileTab>
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
              Expanded(child: _buildProfileOptions(context)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: cardDecoration,
            child: Column(
              children: [
                _buildProfileOption(
                  icon: Icons.person_outline,
                  title: 'Personal Data',
                  onTap: () {
                    // Navigate to personal data screen
                    Navigator.pushNamed(context, '/personal-data');
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildProfileOption(
                  icon: Icons.folder_outlined,
                  title: 'Saved',
                  onTap: () {
                    // Navigate to saved items
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saved Items - Coming Soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Logout button as separate container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardBorderRadius),
              border: Border.all(color: Colors.red, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildProfileOption(
              icon: Icons.logout,
              title: 'Log out',
              isDestructive: true,
              onTap: () {
                showLogoutConfirmation(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : textGray),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: textGray),
      onTap: onTap,
    );
  }
}

// Helper Widgets

class _BookingListItem extends StatelessWidget {
  final Booking booking;
  final bool showRating;

  const _BookingListItem({required this.booking, this.showRating = false});

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
        trailing: Chip(
          label: Text(
            booking.status.toString().split('.').last.toUpperCase(),
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: _getStatusColor().withOpacity(0.1),
          side: BorderSide(color: _getStatusColor()),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking Details - Coming Soon!')),
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
