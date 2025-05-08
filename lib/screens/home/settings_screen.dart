import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onSignOut;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_circle, size: 40, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user?.email ?? 'No email',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: Icon(Icons.lock_reset, color: colorScheme.primary),
              title: const Text('Change Password'),
              onTap: () async {
                // Show a dialog to enter email for password reset
                final emailController = TextEditingController(text: user?.email ?? '');
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Password'),
                    content: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Enter your email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          final email = emailController.text.trim();
                          if (email.isNotEmpty) {
                            await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Password reset email sent!')),
                              );
                            }
                          }
                        },
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                );
              },
            ),
            SwitchListTile(
              secondary: Icon(Icons.dark_mode, color: colorScheme.primary),
              title: const Text('Dark Mode'),
              value: isDarkMode,
              onChanged: onThemeChanged,
            ),
            const Spacer(),
            Center(
              child: FilledButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                onPressed: onSignOut,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 