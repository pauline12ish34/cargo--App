import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'How do I get started as a driver?',
      answer: 'To get started as a driver:\n1. Complete your profile with accurate information\n2. Upload required documents (license, ID, vehicle registration)\n3. Wait for verification (usually 24-48 hours)\n4. Set your status to "Available" to start receiving job requests',
    ),
    FAQItem(
      question: 'What documents do I need to upload?',
      answer: 'Required documents include:\n• Valid driver\'s license\n• National ID\n• Vehicle registration certificate\n• Vehicle insurance certificate\n• Clear photo of your vehicle\n\nAll documents must be current and clearly readable.',
    ),
    FAQItem(
      question: 'How do I receive job notifications?',
      answer: 'Job notifications are sent when:\n• You are marked as "Available"\n• A cargo owner posts a job that matches your vehicle type\n• You are within the delivery area\n\nMake sure push notifications are enabled in Settings.',
    ),
    FAQItem(
      question: 'How is payment handled?',
      answer: 'Payment is negotiated directly between you and the cargo owner. CargoLink facilitates the connection but does not handle payments directly. Always agree on payment terms before starting a job.',
    ),
    FAQItem(
      question: 'What if I have an issue during delivery?',
      answer: 'If you encounter issues:\n1. Contact the cargo owner through the in-app chat\n2. Document the issue with photos if necessary\n3. Contact CargoLink support if needed\n4. Complete the delivery report accurately',
    ),
    FAQItem(
      question: 'How do I update my vehicle information?',
      answer: 'To update vehicle details:\n1. Go to Profile → Vehicle Details\n2. Update the required information\n3. Upload new documents if needed\n4. Save changes\n\nChanges may require re-verification.',
    ),
    FAQItem(
      question: 'Can I cancel a job after accepting?',
      answer: 'While possible, frequent cancellations affect your rating. Only cancel for valid reasons:\n• Vehicle breakdown\n• Emergency situations\n• Safety concerns\n\nAlways communicate with the cargo owner before canceling.',
    ),
    FAQItem(
      question: 'How do ratings work?',
      answer: 'Both drivers and cargo owners rate each other after completing a job:\n• Ratings are from 1-5 stars\n• Your average rating affects job visibility\n• Maintain a high rating for better opportunities\n• Professional service leads to better ratings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.phone,
                    title: 'Call Support',
                    subtitle: '+250 788 123 456',
                    onTap: () {
                      _showContactDialog('Phone', '+250 788 123 456');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.email,
                    title: 'Email Us',
                    subtitle: 'support@cargolink.rw',
                    onTap: () {
                      _showContactDialog('Email', 'support@cargolink.rw');
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.chat,
                    title: 'Live Chat',
                    subtitle: 'Chat with support',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Live Chat - Coming Soon!')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.report_problem,
                    title: 'Report Issue',
                    subtitle: 'Report a problem',
                    onTap: () {
                      _showReportIssueDialog();
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // FAQ Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...List.generate(
              _faqs.length,
              (index) => _buildFAQTile(_faqs[index]),
            ),
            
            const SizedBox(height: 32),
            
            // Resources Section
            const Text(
              'Resources',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildResourceTile(
              icon: Icons.book,
              title: 'Driver Guide',
              subtitle: 'Complete guide for new drivers',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Driver Guide - Coming Soon!')),
                );
              },
            ),
            
            _buildResourceTile(
              icon: Icons.security,
              title: 'Safety Guidelines',
              subtitle: 'Important safety tips and procedures',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Safety Guidelines - Coming Soon!')),
                );
              },
            ),
            
            _buildResourceTile(
              icon: Icons.policy,
              title: 'Terms & Conditions',
              subtitle: 'Read our terms of service',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Terms & Conditions - Coming Soon!')),
                );
              },
            ),
            
            _buildResourceTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy Policy - Coming Soon!')),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Contact Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CargoLink Support',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Available 24/7 to help you succeed'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Response time: Usually within 2 hours',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQTile(FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq.answer,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showContactDialog(String method, String contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact via $method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$method: $contact'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: contact));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening $method app...')),
                      );
                    },
                    icon: Icon(method == 'Phone' ? Icons.phone : Icons.email),
                    label: Text('Open'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showReportIssueDialog() {
    final TextEditingController issueController = TextEditingController();
    String selectedCategory = 'Technical Issue';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Report an Issue'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category:'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'Technical Issue',
                        'App Bug',
                        'Payment Issue',
                        'Safety Concern',
                        'User Behavior',
                        'Other',
                      ].map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Description:'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: issueController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Please describe the issue in detail...',
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (issueController.text.trim().isNotEmpty) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Issue reported successfully! We\'ll get back to you soon.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Report'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}