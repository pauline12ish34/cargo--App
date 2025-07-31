import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/user_model.dart';
import '../core/repositories/user_repository.dart';
import '../providers/auth_provider.dart';
import '../mixins/image_picker_mixin.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> with ImagePickerMixin {
  final _formKey = GlobalKey<FormState>();
  final _vehicleTypeController = TextEditingController();
  final _vehicleCapacityController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _vehicleRegistrationController = TextEditingController();
  
  final UserRepository _userRepository = FirebaseUserRepository();
  
  bool _isLoading = false;
  UserModel? _user;
  
  // Vehicle document files
  File? _vehicleImageFile;
  File? _vehicleRegistrationFile;
  File? _insuranceDocumentFile;
  
  // Upload states
  bool _vehicleImageUploading = false;
  bool _vehicleRegistrationUploading = false;
  bool _insuranceDocumentUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _vehicleCapacityController.dispose();
    _plateNumberController.dispose();
    _insuranceController.dispose();
    _vehicleRegistrationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    
    if (currentUser != null) {
      setState(() {
        _user = currentUser;
        _vehicleTypeController.text = currentUser.vehicleType ?? '';
        _vehicleCapacityController.text = currentUser.vehicleCapacity ?? '';
        _plateNumberController.text = currentUser.plateNumber ?? '';
        _insuranceController.text = currentUser.insurance ?? '';
        _vehicleRegistrationController.text = currentUser.vehicleRegistration ?? '';
      });
    }
  }

  Future<void> _saveVehicleDetails() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;
      
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Upload documents if selected
      Map<String, String> documentUpdates = {};
      
      if (_vehicleImageFile != null) {
        setState(() {
          _vehicleImageUploading = true;
        });
        final url = await _userRepository.uploadDocument(currentUser.uid, _vehicleImageFile!, 'vehicle_image');
        documentUpdates['vehicleImageUrl'] = url;
        setState(() {
          _vehicleImageUploading = false;
        });
      }
      
      if (_vehicleRegistrationFile != null) {
        setState(() {
          _vehicleRegistrationUploading = true;
        });
        final url = await _userRepository.uploadDocument(currentUser.uid, _vehicleRegistrationFile!, 'vehicle_registration');
        documentUpdates['vehicleRegistration'] = url;
        setState(() {
          _vehicleRegistrationUploading = false;
        });
      }
      
      if (_insuranceDocumentFile != null) {
        setState(() {
          _insuranceDocumentUploading = true;
        });
        final url = await _userRepository.uploadDocument(currentUser.uid, _insuranceDocumentFile!, 'insurance_document');
        documentUpdates['insurance'] = url;
        setState(() {
          _insuranceDocumentUploading = false;
        });
      }

      // Update vehicle information
      final updatedUser = currentUser.copyWith(
        vehicleType: _vehicleTypeController.text.trim(),
        vehicleCapacity: _vehicleCapacityController.text.trim(),
        plateNumber: _plateNumberController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await _userRepository.updateUser(updatedUser);
      
      // Update documents if any were uploaded
      if (documentUpdates.isNotEmpty) {
        await _userRepository.updateUserWithDocuments(currentUser.uid, documentUpdates);
      }

      // Refresh auth provider with updated user
      await authProvider.refreshUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle details updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating vehicle details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String description,
    required VoidCallback onTap,
    required bool isUploading,
    String? currentUrl,
    File? selectedFile,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selectedFile != null || currentUrl != null 
                    ? Icons.check_circle 
                    : Icons.upload_file,
                  color: selectedFile != null || currentUrl != null 
                    ? Colors.green 
                    : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (selectedFile != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.file_present, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedFile.path.split('/').last,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (currentUrl != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_done, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Document uploaded',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUploading ? null : onTap,
                icon: isUploading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload, size: 18),
                label: Text(
                  isUploading 
                    ? 'Uploading...' 
                    : selectedFile != null || currentUrl != null 
                      ? 'Replace Document' 
                      : 'Upload Document',
                  style: const TextStyle(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveVehicleDetails,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Information
              const Text(
                'Vehicle Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _vehicleTypeController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type *',
                  hintText: 'e.g., Pickup Truck, Mini Truck, Large Truck',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your vehicle type';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _vehicleCapacityController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Capacity *',
                  hintText: 'e.g., 1 ton, 5 tons, 500 kg',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your vehicle capacity';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _plateNumberController,
                decoration: const InputDecoration(
                  labelText: 'Plate Number *',
                  hintText: 'e.g., RAB 123 A',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your vehicle plate number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Vehicle Documents
              const Text(
                'Vehicle Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload your vehicle-related documents for verification',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildDocumentUploadCard(
                title: 'Vehicle Photo',
                description: 'Upload a clear photo of your vehicle',
                onTap: () {
                  showDocumentPickerDialog(
                    context,
                    'Vehicle Photo',
                    onDocumentSelected: (file) {
                      setState(() {
                        _vehicleImageFile = file;
                      });
                    },
                  );
                },
                isUploading: _vehicleImageUploading,
                currentUrl: _user?.vehicleImageUrl,
                selectedFile: _vehicleImageFile,
              ),
              
              _buildDocumentUploadCard(
                title: 'Vehicle Registration',
                description: 'Upload your vehicle registration certificate',
                onTap: () {
                  showDocumentPickerDialog(
                    context,
                    'Vehicle Registration',
                    onDocumentSelected: (file) {
                      setState(() {
                        _vehicleRegistrationFile = file;
                      });
                    },
                  );
                },
                isUploading: _vehicleRegistrationUploading,
                currentUrl: _user?.vehicleRegistration,
                selectedFile: _vehicleRegistrationFile,
              ),
              
              _buildDocumentUploadCard(
                title: 'Insurance Document',
                description: 'Upload your vehicle insurance certificate',
                onTap: () {
                  showDocumentPickerDialog(
                    context,
                    'Insurance Document',
                    onDocumentSelected: (file) {
                      setState(() {
                        _insuranceDocumentFile = file;
                      });
                    },
                  );
                },
                isUploading: _insuranceDocumentUploading,
                currentUrl: _user?.insurance,
                selectedFile: _insuranceDocumentFile,
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveVehicleDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Vehicle Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}