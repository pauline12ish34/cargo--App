import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/user_model.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/repositories/user_repository.dart';
import '../../../providers/auth_provider.dart';
import '../core/enums/app_enums.dart' hide VehicleType;
import '../features/booking/providers/booking_provider.dart';

class DriverSelectionScreen extends StatefulWidget {
  final VehicleType vehicleType;
  final String pickupLocation;
  final String dropoffLocation;
  final String cargoDescription;
  final bool isReassignment;
  final String? bookingId;

  const DriverSelectionScreen({
    super.key,
    required this.vehicleType,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.cargoDescription,
    this.isReassignment = false,
    this.bookingId,
  });

  @override
  State<DriverSelectionScreen> createState() => _DriverSelectionScreenState();
}

class _DriverSelectionScreenState extends State<DriverSelectionScreen> {
  List<UserModel> _availableDrivers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAvailableDrivers();
  }

  Future<void> _loadAvailableDrivers() async {
    try {
      final userRepository = Provider.of<UserRepository>(context, listen: false);
      final drivers = await userRepository.getUsersByRole(UserRole.driver);

      final availableDrivers = drivers
          .where((driver) => driver.isAvailable == true && driver.rating != null)
          .toList();

      setState(() {
        _availableDrivers = availableDrivers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load drivers: $e';
        _isLoading = false;
      });
    }
  }

  void _selectDriver(UserModel driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isReassignment ? 'Reassign to Driver' : 'Confirm Driver Selection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Driver: ${driver.name}'),
            Text('Rating: ${driver.rating?.toStringAsFixed(1) ?? 'No rating'} ⭐'),
            Text('Completed Jobs: ${driver.completedJobs ?? 0}'),
            const SizedBox(height: 16),
            const Text('Job Details:'),
            Text('From: ${widget.pickupLocation}'),
            Text('To: ${widget.dropoffLocation}'),
            Text('Cargo: ${widget.cargoDescription}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendJobRequest(driver);
            },
            child: Text(widget.isReassignment ? 'Reassign' : 'Send Request'),
          ),
        ],
      ),
    );
  }

  void _sendJobRequest(UserModel driver) async {
    if (widget.isReassignment && widget.bookingId != null) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final success = await bookingProvider.reassignBooking(widget.bookingId!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job reassigned successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bookingProvider.error ?? 'Failed to reassign job'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job request sent to ${driver.name}'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isReassignment ? 'Reassign Job' : 'Select Driver'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadAvailableDrivers();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _availableDrivers.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_accounts, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No available drivers found', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Please try again later', style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Job Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Vehicle Type: ${widget.vehicleType.toString().split('.').last}'),
                Text('From: ${widget.pickupLocation}'),
                Text('To: ${widget.dropoffLocation}'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _availableDrivers.length,
              itemBuilder: (context, index) {
                final driver = _availableDrivers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        driver.name.isNotEmpty
                            ? driver.name[0].toUpperCase()
                            : 'D',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      driver.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(
                              driver.rating?.toStringAsFixed(1) ?? 'No rating',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.work, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${driver.completedJobs ?? 0} jobs',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _selectDriver(driver),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Select'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
