import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_service.dart';
import 'inventory_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user details from Firestore
  Future<Map<String, dynamic>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';

    if (username.isEmpty) {
      await Future.delayed(const Duration(seconds: 1)); // Add delay to allow data to sync
      return getUserDetails(); // Retry fetching data
    }

    try {
      final userDoc = await _firestore.collection('users').doc(username).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return {
          'nickname': userData['nickname'] ?? 'No Nickname',
          'level': userData['level'] ?? 1,
          'email': userData['email'] ?? 'No Email',
          'phoneNumber': userData['phoneNumber'] ?? 'No Phone Number',
          'birthDate': userData['birthDate'] ?? 'No Birth Date',
          'avatar': userData['avatar'] ?? '',
          'currentXP': userData['currentXP'] ?? 0,
          'totalXP': userData['totalXP'] ?? 100,
          'CO2saved': userData['CO2saved'] ?? 0,
        };
      } else {
        return Future.delayed(const Duration(seconds: 1), getUserDetails);
      }
    } catch (e) {
      print("Error fetching user data from Firestore: $e");
      return {
        'nickname': 'Error',
        'level': 1,
        'email': 'No Email',
        'phoneNumber': 'No Phone Number',
        'birthDate': 'No Birth Date',
        'avatar': '',
        'currentXP': 0,
        'totalXP': 100,
        'CO2saved': 0,
      };
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading profile.'));
          }

          final userDetails = snapshot.data!;
          final profileImage = userDetails['profileImage'] ?? ''; // Default if no image
          final currentXP = userDetails['currentXP'] ?? 0; // Current XP of the user
          final totalXP = userDetails['totalXP'] ?? 100; // Total XP required for next level

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 300,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.lightGreen, Colors.green],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                      ),
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: userDetails['avatar'].isNotEmpty
                              ? AssetImage(userDetails['avatar'])
                              : const AssetImage('assets/default_profile.png') as ImageProvider,
                        ),

                        const SizedBox(height: 16),
                        Text(
                          userDetails['nickname'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Level ${userDetails['level']}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: currentXP / totalXP,
                                  backgroundColor: Colors.white38,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                                  minHeight: 10,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$currentXP / $totalXP XP',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email, color: Colors.green),
                        title: Text(
                          userDetails['email'] ?? 'No Email',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.phone, color: Colors.green),
                        title: Text(
                          userDetails['phoneNumber'] ?? 'No Phone Number',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.cake, color: Colors.green),
                        title: Text(
                          userDetails['birthDate'] ?? 'No Birth Date',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton(
                    onPressed: () => logout(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(200),
                      ),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InventoryScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(200),
                      ),
                    ),
                    child: const Text(
                      'View Inventory',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
