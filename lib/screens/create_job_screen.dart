import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/booking_model.dart';
import '../../../features/booking/providers/booking_provider.dart';
import '../../../providers/auth_provider.dart';
import 'driver_selection_screen.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _cargoDescriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  final _estimatedPriceController = TextEditingController();

  VehicleType _selectedVehicleType = VehicleType.miniTruck;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _cargoDescriptionController.dispose();
    _weightController.dispose();
    _specialInstructionsController.dispose();
    _estimatedPriceController.dispose();
    super.dispose();
  }

  Future<void> _createJob() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create a job')),
      );
      return;
    }

    final success = await bookingProvider.createBooking(
      cargoOwnerId: authProvider.user!.uid,
      pickupLocation: _pickupController.text.trim(),
      dropoffLocation: _dropoffController.text.trim(),
      cargoDescription: _cargoDescriptionController.text.trim(),
      vehicleType: _selectedVehicleType,
      weight: _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null,
      specialInstructions: _specialInstructionsController.text.isNotEmpty
          ? _specialInstructionsController.text.trim()
          : null,
      estimatedPrice: _estimatedPriceController.text.isNotEmpty
          ? double.tryParse(_estimatedPriceController.text)
          : null,
    );

    if (success && mounted) {
      // Navigate to driver selection screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DriverSelectionScreen(
            vehicleType: _selectedVehicleType,
            pickupLocation: _pickupController.text.trim(),
            dropoffLocation: _dropoffController.text.trim(),
            cargoDescription: _cargoDescriptionController.text.trim(),
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.error ?? 'Failed to create job'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Job'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    'Job Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pickup Location
                  TextFormField(
                    controller: _pickupController,
                    decoration: const InputDecoration(
                      labelText: 'Pickup Location *',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pickup location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Dropoff Location
                  TextFormField(
                    controller: _dropoffController,
                    decoration: const InputDecoration(
                      labelText: 'Dropoff Location *',
                      prefixIcon: Icon(Icons.flag),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter dropoff location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Cargo Description
                  TextFormField(
                    controller: _cargoDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Cargo Description *',
                      prefixIcon: Icon(Icons.inventory),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please describe your cargo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Type
                  DropdownButtonFormField<VehicleType>(
                    value: _selectedVehicleType,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Type *',
                      prefixIcon: Icon(Icons.local_shipping),
                      border: OutlineInputBorder(),
                    ),
                    items: VehicleType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getVehicleTypeDisplayName(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedVehicleType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Weight (Optional)
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      prefixIcon: Icon(Icons.scale),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Estimated Price (Optional)
                  TextFormField(
                    controller: _estimatedPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Estimated Price (RWF)',
                      prefixIcon: Icon(Icons.money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Special Instructions (Optional)
                  TextFormField(
                    controller: _specialInstructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Special Instructions',
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Create Job Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: bookingProvider.isLoading ? null : _createJob,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: bookingProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'CREATE JOB',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getVehicleTypeDisplayName(VehicleType type) {
    switch (type) {
      case VehicleType.miniTruck:
        return 'Mini Truck';
      case VehicleType.pickup:
        return 'Pickup';
      case VehicleType.largeTruck:
        return 'Large Truck';
      case VehicleType.van:
        return 'Van';
      case VehicleType.motorcycle:
        return 'Motorcycle';
    }
  }
}