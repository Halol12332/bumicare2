import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatelessWidget {
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Hapus status login
    await prefs.remove('username'); // Opsional: Hapus username

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login', // Arahkan ke layar login
          (route) => false, // Bersihkan semua rute sebelumnya
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Column(
        children: [
          // Profile Image and Level Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Circular Profile Image
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('../assets/img.png'), // Replace with your asset or network image
                ),
                const SizedBox(height: 16),
                // User Level
                const Text(
                  'Level 3',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // XP Progress
                Column(
                  children: [
                    const Text(
                      'XP: 75/100',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.75, // XP progress (75/100)
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Achievements Section
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    // List of Achievements
                    AchievementCard(
                      title: 'First Login',
                      description: 'Logged in for the first time!',
                    ),
                    AchievementCard(
                      title: '5-Day Streak',
                      description: 'Logged in for 5 consecutive days!',
                    ),
                    AchievementCard(
                      title: 'Challenge Master',
                      description: 'Completed 10 challenges!',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Rewards Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/rewards');
              },
              child: const Text(
                'Go to Rewards',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          // Log Out Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red), // Red border
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => logout(context), // Perbarui fungsi logout
              child: const Text(
                'Log Out',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Achievement Card Widget
class AchievementCard extends StatelessWidget {
  final String title;
  final String description;

  const AchievementCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
