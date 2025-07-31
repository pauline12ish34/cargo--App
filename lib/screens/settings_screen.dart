import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/repositories/user_repository.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserRepository _userRepository = FirebaseUserRepository();
  
  bool _isLoading = false;
  
  // Settings
  bool _isAvailable = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    
    if (currentUser != null) {
      setState(() {
        _isAvailable = currentUser.isAvailable ?? false;
        // These would be loaded from user preferences in a real app
        _pushNotifications = true;
        _emailNotifications = true;
        _smsNotifications = false;
      });
    }
  }

  Future<void> _updateAvailability(bool value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;
      
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final updatedUser = currentUser.copyWith(
        isAvailable: value,
        updatedAt: DateTime.now(),
      );

      await _userRepository.updateUser(updatedUser);
      await authProvider.refreshUserData();

      if (mounted) {
        setState(() {
          _isAvailable = value;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value 
                ? 'You are now available for jobs'
                : 'You are now unavailable for jobs',
            ),
            backgroundColor: value ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating availability: $e'),
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

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: Icon(icon, color: enabled ? Theme.of(context).primaryColor : Colors.grey),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: enabled ? Colors.black87 : Colors.grey,
          ),
        ),
        subtitle: subtitle != null 
          ? Text(
              subtitle,
              style: TextStyle(
                color: enabled ? Colors.grey[600] : Colors.grey,
                fontSize: 12,
              ),
            )
          : null,
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.black87,
          ),
        ),
        subtitle: subtitle != null 
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            )
          : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Status Section
            const Text(
              'Driver Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Control your availability to receive job requests',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildSettingsTile(
              icon: _isAvailable ? Icons.work : Icons.work_off,
              title: 'Available for Jobs',
              subtitle: _isAvailable 
                ? 'You will receive job notifications'
                : 'You won\'t receive job notifications',
              value: _isAvailable,
              onChanged: _updateAvailability,
              enabled: !_isLoading,
            ),
            
            const SizedBox(height: 32),
            
            // Notification Settings
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage how you receive notifications',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildSettingsTile(
              icon: Icons.notifications,
              title: 'Push Notifications',
              subtitle: 'Receive instant notifications on your device',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
                // Here you would save the preference to user settings
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value 
                        ? 'Push notifications enabled'
                        : 'Push notifications disabled',
                    ),
                  ),
                );
              },
            ),
            
            _buildSettingsTile(
              icon: Icons.email,
              title: 'Email Notifications',
              subtitle: 'Receive job updates via email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value 
                        ? 'Email notifications enabled'
                        : 'Email notifications disabled',
                    ),
                  ),
                );
              },
            ),
            
            _buildSettingsTile(
              icon: Icons.sms,
              title: 'SMS Notifications',
              subtitle: 'Receive job alerts via SMS',
              value: _smsNotifications,
              onChanged: (value) {
                setState(() {
                  _smsNotifications = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value 
                        ? 'SMS notifications enabled'
                        : 'SMS notifications disabled',
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Account Settings
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildActionTile(
              icon: Icons.security,
              title: 'Privacy & Security',
              subtitle: 'Manage your account security settings',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy & Security - Coming Soon!')),
                );
              },
            ),
            
            _buildActionTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'Change app language',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language Settings - Coming Soon!')),
                );
              },
            ),
            
            _buildActionTile(
              icon: Icons.dark_mode,
              title: 'Theme',
              subtitle: 'Light, Dark, or System',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme Settings - Coming Soon!')),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // App Settings
            const Text(
              'App',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildActionTile(
              icon: Icons.info,
              title: 'About',
              subtitle: 'App version and information',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'CargoLink Rwanda',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.local_shipping, size: 48),
                  children: [
                    const Text('Connecting cargo owners with reliable drivers across Rwanda.'),
                  ],
                );
              },
            ),
            
            _buildActionTile(
              icon: Icons.feedback,
              title: 'Send Feedback',
              subtitle: 'Help us improve the app',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback - Coming Soon!')),
                );
              },
            ),
            
            _buildActionTile(
              icon: Icons.star_rate,
              title: 'Rate App',
              subtitle: 'Rate CargoLink on the app store',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rate App - Coming Soon!')),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Danger Zone
            const Text(
              'Account Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildActionTile(
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: 'Sign out of your account',
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            await authProvider.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            }
                          },
                          child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}