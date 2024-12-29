//settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Settings",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSettingOption(
                  context,
                  "Account",
                  "Change your account information",
                  "../assets/account_icon.png",
                      () {},
                ),
                const SizedBox(height: 20),
                _buildSettingOption(
                  context,
                  "Privacy",
                  "Change your password",
                  "../assets/privacy_icon.jpg",
                      () {},
                ),
                const SizedBox(height: 20),
                _buildSettingOption(
                  context,
                  "Notifications",
                  "Open or close the app notifications",
                  "../assets/notifications_icon.jpg",
                      () {},
                ),
                const SizedBox(height: 20),
                _buildSettingOption(
                  context,
                  "Add Social Account",
                  "Add Facebook, Twitter etc.",
                  "../assets/social_icon.jpg",
                      () {},
                ),
                const SizedBox(height: 20),
                _buildSettingOption(
                  context,
                  "Refer to Friends",
                  "Get RM50 for referring friends",
                  "../assets/refer_icon.jpg",
                      () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingOption(
      BuildContext context,
      String title,
      String subTitle,
      String iconSrc,
      VoidCallback onTap,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              iconSrc,
              width: 24,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        TextButton(
          onPressed: onTap,
          child: const Icon(
            Icons.arrow_forward_ios_outlined,
            size: 20,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
