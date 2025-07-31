import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

class DriverSignupScreen extends StatefulWidget {
  
   final String? initialName;
  final String? initialEmail;
  final String? initialPhone;
  final String? initialPassword;

  const DriverSignupScreen({
    super.key,
    this.initialName,
    this.initialEmail,
    this.initialPhone,
    this.initialPassword,
  });

  @override
  _DriverSignupScreenState createState() => _DriverSignupScreenState();
}

class _DriverSignupScreenState extends State<DriverSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _obscurePassword = true;

  

  // Basic info controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // Driver info controllers
  final driverLicenseController = TextEditingController();
  final plateNumberController = TextEditingController();
  final insuranceController = TextEditingController();
  final nationalIdController = TextEditingController();
  final vehicleRegistrationController = TextEditingController();
  final vehicleTypeController = TextEditingController();
  final vehicleCapacityController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    driverLicenseController.dispose();
    plateNumberController.dispose();
    insuranceController.dispose();
    nationalIdController.dispose();
    vehicleRegistrationController.dispose();
    vehicleTypeController.dispose();
    vehicleCapacityController.dispose();
    super.dispose();
  }

@override
void initState() {
  super.initState();
  if (widget.initialName != null) nameController.text = widget.initialName!;
  if (widget.initialEmail != null) emailController.text = widget.initialEmail!;
  if (widget.initialPhone != null) phoneController.text = widget.initialPhone!;
  if (widget.initialPassword != null) passwordController.text = widget.initialPassword!;
}

  Future<void> _completeRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // First create the basic user account
    final success = await authProvider.signUp(
      email: emailController.text.trim(),
      password: passwordController.text,
      name: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      role: UserRole.driver,
    );

    if (success && mounted) {
      // Then update with driver-specific information
      final updateSuccess = await authProvider.updateDriverDocuments(
        driverLicense: driverLicenseController.text.trim(),
        nationalId: nationalIdController.text.trim(),
        vehicleRegistration: vehicleRegistrationController.text.trim(),
        vehicleType: vehicleTypeController.text.trim(),
        vehicleCapacity: vehicleCapacityController.text.trim(),
        plateNumber: plateNumberController.text.trim(),
        insurance: insuranceController.text.trim(),
      );

      if (updateSuccess && mounted) {
        Navigator.pushReplacementNamed(context, '/email-verification');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Driver details update failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Signup failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Basic Info'),
        content: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^\+?[0-9]{10,}$').hasMatch(value.replaceAll(' ', ''))) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_android),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Driver License'),
        content: Column(
          children: [
            TextFormField(
              controller: driverLicenseController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter driver license number';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Driver License Number',
                prefixIcon: Icon(Icons.card_membership),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nationalIdController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter national ID';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'National ID',
                prefixIcon: Icon(Icons.perm_identity),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Vehicle Info'),
        content: Column(
          children: [
            TextFormField(
              controller: plateNumberController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter plate number';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Plate Number',
                prefixIcon: Icon(Icons.directions_car),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: vehicleRegistrationController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vehicle registration';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Vehicle Registration Number',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: vehicleTypeController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vehicle type';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Vehicle Type (e.g., Truck, Van)',
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: vehicleCapacityController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vehicle capacity';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Vehicle Capacity (kg)',
                prefixIcon: Icon(Icons.line_weight),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: insuranceController,
              decoration: const InputDecoration(
                labelText: 'Insurance Information (optional)',
                prefixIcon: Icon(Icons.security),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  void _stepContinue() {
    if (_currentStep == _buildSteps().length - 1) {
      _completeRegistration();
    } else {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _stepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Registration'),
      ),
      body:
      
      
      Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.green, // This changes the stepper color
          secondary: Colors.green.shade200, // Color for the text/icons
        ),
        
      ),
      child: Stepper( 
        currentStep: _currentStep,
        steps: _buildSteps(),
        onStepContinue: _stepContinue,
        onStepCancel: _stepCancel,
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          final authProvider = Provider.of<AuthProvider>(context);
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                if (_currentStep != 0)
                  ElevatedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('BACK'),
                  ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: authProvider.isLoading && _currentStep == _buildSteps().length - 1
                      ? const CircularProgressIndicator()
                      : Text(_currentStep == _buildSteps().length - 1 ? 'COMPLETE' : 'NEXT'),
                ),
              ],
            ),
          );
        },
      ),

    )
    );
  }
}