import 'package:flutter/material.dart';

import 'account_setting.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildInteractiveSetting(
              context,
              "Account",
              "Change your account information",
              Icons.person,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeAccountInfoScreen()),
                );
              },
            ),
            const Divider(thickness: 1, color: Colors.grey),
            _buildInteractiveSetting(
              context,
              "Privacy",
              "Change your password",
              Icons.lock,
                  () {
                // Handle privacy option
              },
            ),
            const Divider(thickness: 1, color: Colors.grey),
            _buildInteractiveSetting(
              context,
              "Notifications",
              "Manage notifications",
              Icons.notifications,
                  () {
                // Handle notifications option
              },
            ),
            const Divider(thickness: 1, color: Colors.grey),
            _buildInteractiveSetting(
              context,
              "Social Accounts",
              "Connect Facebook, Twitter, etc.",
              Icons.share,
                  () {
                // Handle social accounts option
              },
            ),
            const Divider(thickness: 1, color: Colors.grey),
            _buildInteractiveSetting(
              context,
              "Refer to Friends",
              "Get RM50 for referrals",
              Icons.card_giftcard,
                  () {
                // Handle refer to friends option
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveSetting(
      BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.black,
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.grey,
      ),
      onTap: onTap,
      tileColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
