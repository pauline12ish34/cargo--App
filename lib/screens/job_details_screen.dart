import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/repositories/user_repository.dart';
import '../../../features/booking/providers/booking_provider.dart';
import '../../../providers/auth_provider.dart';
import '../core/enums/app_enums.dart' hide BookingStatus;
import '../features/chat/chat_screen.dart';
import '../screens/driver_selection_screen.dart';
import 'package:cargo_app/constants.dart';

class JobDetailsScreen extends StatefulWidget {
  final BookingModel booking;

  const JobDetailsScreen({
    super.key,
    required this.booking,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  UserModel? _assignedDriver;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDriverInfo();
  }

  Future<void> _loadDriverInfo() async {
    if (widget.booking.driverId != null) {
      setState(() => _isLoading = true);
      try {
        final userRepository = Provider.of<UserRepository>(context, listen: false);
        final driver = await userRepository.getUserById(widget.booking.driverId!);
        setState(() => _assignedDriver = driver);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load driver info: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // final isCargoOwner = authProvider.user?.role == UserRole.cargoOwner;
    final isCargoOwner = authProvider.user?.role.name == 'cargoOwner';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          if (widget.booking.status == BookingStatus.accepted &&
              widget.booking.driverId != null)
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: _openChat,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            _StatusBanner(booking: widget.booking),
            const SizedBox(height: 24),

            // Job Information
            _SectionCard(
              title: 'Job Information',
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.inventory,
                    label: 'Cargo Description',
                    value: widget.booking.cargoDescription,
                  ),
                  _InfoRow(
                    icon: Icons.location_on,
                    label: 'Pickup Location',
                    value: widget.booking.pickupLocation,
                  ),
                  _InfoRow(
                    icon: Icons.flag,
                    label: 'Dropoff Location',
                    value: widget.booking.dropoffLocation,
                  ),
                  _InfoRow(
                    icon: Icons.local_shipping,
                    label: 'Vehicle Type',
                    value: widget.booking.vehicleTypeDisplayName,
                  ),
                  if (widget.booking.weight != null)
                    _InfoRow(
                      icon: Icons.scale,
                      label: 'Weight',
                      value: '${widget.booking.weight}kg',
                    ),
                  if (widget.booking.estimatedPrice != null)
                    _InfoRow(
                      icon: Icons.money,
                      label: 'Estimated Price',
                      value: '${widget.booking.estimatedPrice!.toStringAsFixed(0)} RWF',
                    ),
                  if (widget.booking.specialInstructions?.isNotEmpty == true)
                    _InfoRow(
                      icon: Icons.note,
                      label: 'Special Instructions',
                      value: widget.booking.specialInstructions!,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Driver Information (if assigned)
            if (_assignedDriver != null) ...[
              _SectionCard(
                title: 'Assigned Driver',
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: primaryGreen,
                          child: Text(
                            _assignedDriver!.name.isNotEmpty
                                ? _assignedDriver!.name[0].toUpperCase()
                                : 'D',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _assignedDriver!.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_assignedDriver!.rating?.toStringAsFixed(1) ?? 'No rating'}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.work, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_assignedDriver!.completedJobs ?? 0} jobs',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.booking.status == BookingStatus.accepted) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openChat,
                          icon: const Icon(Icons.chat),
                          label: const Text('Open Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Timeline
            _SectionCard(
              title: 'Timeline',
              child: Column(
                children: [
                  _TimelineItem(
                    icon: Icons.add_circle,
                    title: 'Job Created',
                    subtitle: _formatDateTime(widget.booking.createdAt),
                    isCompleted: true,
                  ),
                  if (widget.booking.acceptedAt != null)
                    _TimelineItem(
                      icon: Icons.check_circle,
                      title: 'Job Accepted',
                      subtitle: _formatDateTime(widget.booking.acceptedAt!),
                      isCompleted: true,
                    ),
                  if (widget.booking.status == BookingStatus.declined)
                    _TimelineItem(
                      icon: Icons.cancel,
                      title: 'Job Declined',
                      subtitle: 'Driver declined this job',
                      isCompleted: true,
                      isError: true,
                    ),
                  if (widget.booking.completedAt != null)
                    _TimelineItem(
                      icon: Icons.check_circle_outline,
                      title: 'Job Completed',
                      subtitle: _formatDateTime(widget.booking.completedAt!),
                      isCompleted: true,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (isCargoOwner) ..._buildCargoOwnerActions(),
            if (!isCargoOwner) ..._buildDriverActions(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCargoOwnerActions() {
    switch (widget.booking.status) {
      case BookingStatus.pending:
        return [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cancelJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel Job'),
            ),
          ),
        ];
      case BookingStatus.declined:
        return [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _reassignJob,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Reassign Driver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _cancelJob,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Cancel Job'),
            ),
          ),
        ];
      case BookingStatus.accepted:
      case BookingStatus.inProgress:
        return [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openChat,
              icon: const Icon(Icons.chat),
              label: const Text('Chat with Driver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ];
      case BookingStatus.completed:
        return [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 12),
                Text(
                  'Job completed successfully!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ];
      case BookingStatus.cancelled:
        return [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.cancel, color: Colors.red),
                SizedBox(width: 12),
                Text(
                  'Job was cancelled',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ];
    }
  }

  List<Widget> _buildDriverActions() {
    switch (widget.booking.status) {
      case BookingStatus.accepted:
        return [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openChat,
              icon: const Icon(Icons.chat),
              label: const Text('Chat with Cargo Owner'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark as Completed'),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  void _openChat() {
    if (_assignedDriver == null && widget.booking.driverId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading driver information...')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isCargoOwner = authProvider.user?.role == UserRole.cargoOwner;

    String otherUserName;
    if (isCargoOwner) {
      otherUserName = _assignedDriver?.name ?? 'Driver';
    } else {
      // For drivers, we need to get cargo owner name (you might want to load this)
      otherUserName = 'Cargo Owner';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          booking: widget.booking,
          otherUserName: otherUserName,
        ),
      ),
    );
  }

  void _reassignJob() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverSelectionScreen(
          vehicleType: widget.booking.vehicleType,
          pickupLocation: widget.booking.pickupLocation,
          dropoffLocation: widget.booking.dropoffLocation,
          cargoDescription: widget.booking.cargoDescription,
          isReassignment: true,
          bookingId: widget.booking.id,
        ),
      ),
    ).then((result) async {
      // After reassigning, refresh the driver info and show a snackbar if reassigned
      await _loadDriverInfo();
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job reassigned to a new driver.'),
            backgroundColor: primaryGreen,
          ),
        );
      }
    });
  }

  void _cancelJob() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Job'),
        content: const Text('Are you sure you want to cancel this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final success = await bookingProvider.cancelBooking(widget.booking.id);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job cancelled successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _completeJob() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Job'),
        content: const Text('Mark this job as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final success = await bookingProvider.completeBooking(widget.booking.id);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBanner extends StatelessWidget {
  final BookingModel booking;

  const _StatusBanner({required this.booking});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusMessage;

    switch (booking.status) {
      case BookingStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusMessage = 'Waiting for driver acceptance';
        break;
      case BookingStatus.accepted:
        statusColor = primaryGreen;
        statusIcon = Icons.check_circle;
        statusMessage = 'Driver has accepted your job';
        break;
      case BookingStatus.inProgress:
        statusColor = Colors.purple;
        statusIcon = Icons.local_shipping;
        statusMessage = 'Job is in progress';
        break;
      case BookingStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        statusMessage = 'Job completed successfully';
        break;
      case BookingStatus.declined:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusMessage = 'Driver declined this job';
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusMessage = 'Job was cancelled';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.statusDisplayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: statusColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isError;

  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red : (isCompleted ? Colors.green : Colors.grey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}