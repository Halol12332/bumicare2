import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          'exp': userData['exp'] ?? 0, // Total accumulated XP
          'CO2saved': userData['CO2saved'] ?? 0, // Total CO2 saved
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
        'exp': 0,
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
          final double co2Saved = userDetails['CO2saved']?.toDouble() ?? 0.0; // CO2 saved
          final String email = userDetails['email'] ?? 'No Email';
          final String phoneNumber = userDetails['phoneNumber'] ?? 'No Phone Number';
          final String birthDate = userDetails['birthDate'] ?? 'No Birth Date';
          final int exp = userDetails['exp'] ?? 0; // Current XP
          final int level = userDetails['level'] ?? 1; // User Level

          // Calculate progress for XP bar (max XP is 100)
          double xpProgress = exp / 100.0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 330,
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
                          'Level $level',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // XP Progress Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              LinearProgressIndicator(
                                value: xpProgress, // Progress of XP
                                minHeight: 8,
                                backgroundColor: Colors.white70,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'XP: $exp/100',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Menampilkan Total CO2 Saved
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const Text(
                                'Total CO2 Saved',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${co2Saved.toStringAsFixed(2)} kg',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Icon untuk representasi CO2 yang diselamatkan
                              Icon(
                                Icons.eco,
                                size: 40,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // User Details Section (Email, Phone, Birth Date)
                Container(
                  padding: const EdgeInsets.all(16),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildUserDetailItem('Email', email),
                      _buildUserDetailItem('Phone Number', phoneNumber),
                      _buildUserDetailItem('Birth Date', birthDate),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Achievements Section
                Container(
                  padding: const EdgeInsets.all(16),
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
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildAchievementBadge('../assets/achievements_logo/first_login.jpg', 'First Login'),
                          _buildAchievementBadge('../assets/achievements_logo/eco_saver.png', 'Eco Saver'),
                          // Add more achievements here
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper function to build user detail item (Email, Phone Number, Birth Date)
  Widget _buildUserDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build achievement badges
  Widget _buildAchievementBadge(String assetPath, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(assetPath),
          backgroundColor: Colors.grey[200],
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

