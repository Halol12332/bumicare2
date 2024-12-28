//leaderboards_screen.dart

import 'package:flutter/material.dart';

class LeaderboardsScreen extends StatelessWidget {
  const LeaderboardsScreen({super.key});

  final List<Map<String, dynamic>> _leaderboardData = const [
    {"name": "Alice", "points": 1200, "profilePic": "assets/avatar1.png"},
    {"name": "Bob", "points": 1150, "profilePic": "assets/avatar2.png"},
    {"name": "Charlie", "points": 1100, "profilePic": "assets/avatar3.png"},
    {"name": "David", "points": 1050, "profilePic": "assets/avatar4.png"},
    {"name": "Eva", "points": 1000, "profilePic": "assets/avatar5.png"},
    {"name": "Frank", "points": 950, "profilePic": "assets/avatar6.png"},
    {"name": "Grace", "points": 900, "profilePic": "assets/avatar7.png"},
    {"name": "Helen", "points": 850, "profilePic": "assets/avatar8.png"},
    {"name": "Irene", "points": 800, "profilePic": "assets/avatar9.png"},
    {"name": "Jack", "points": 750, "profilePic": "assets/avatar10.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Top 10 Players",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _leaderboardData.length,
                itemBuilder: (context, index) {
                  final player = _leaderboardData[index];
                  return _buildLeaderboardTile(
                      index + 1, player['profilePic'], player['name'], player['points']);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTile(int rank, String profilePic, String name, int points) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(profilePic),
          radius: 30,
        ),
        title: Text(
          name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text("Points: $points"),
        trailing: CircleAvatar(
          backgroundColor: _getRankColor(rank),
          child: Text(
            "$rank",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blueGrey;
    }
  }
}