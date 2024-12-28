//note this is profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProfileScreen extends StatelessWidget {
  Future<Map<String, dynamic>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final accountsJson = prefs.getString('accounts') ?? '[]';
    final List<dynamic> accounts = jsonDecode(accountsJson);

    final user = accounts.firstWhere(
          (account) => account['username'] == username,
      orElse: () => null,
    );

    return user != null
        ? {
      'nickname': user['nickname'] ?? 'No Nickname',
      'level': user['level'] ?? 1,
    }
        : {'nickname': 'Unknown', 'level': 1};
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('profile_screen.dart'),),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading profile.'));
          }

          final userDetails = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('../assets/img.png'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userDetails['nickname'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Level ${userDetails['level']}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Text('Additional Details or Achievements here'),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: OutlinedButton(
                  onPressed: () => logout(context),
                  child: const Text('Log Out'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
