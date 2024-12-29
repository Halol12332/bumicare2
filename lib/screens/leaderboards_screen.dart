import 'package:flutter/material.dart';

class LeaderboardsScreen extends StatelessWidget {
  const LeaderboardsScreen({super.key});

  final List<Map<String, dynamic>> _leaderboardData = const [
    {"name": "Alice", "level": 120, "profilePic": "../assets/avatar_leaderboards/avatar1.png"},
    {"name": "Bob", "level": 115, "profilePic": "../assets/avatar_leaderboards/avatar2.png"},
    {"name": "Charlie", "level": 110, "profilePic": "../assets/avatar_leaderboards/avatar3.png"},
    {"name": "David", "level": 105, "profilePic": "../assets/avatar_leaderboards/avatar4.png"},
    {"name": "Eva", "level": 100, "profilePic": "../assets/avatar_leaderboards/avatar5.png"},
    {"name": "Frank", "level": 95, "profilePic": "../assets/avatar_leaderboards/avatar6.png"},
    {"name": "Grace", "level": 90, "profilePic": "../assets/avatar_leaderboards/avatar7.png"},
    {"name": "Helen", "level": 85, "profilePic": "../assets/avatar_leaderboards/avatar8.png"},
    {"name": "Irene", "level": 80, "profilePic": "../assets/avatar_leaderboards/avatar9.png"},
    {"name": "Jack", "level": 75, "profilePic": "../assets/avatar_leaderboards/avatar10.png"},
  ];

  final Map<String, dynamic> _currentUser = const {
    "name": "You",
    "level": 4,
    "profilePic": "../assets/avatar_leaderboards/avatar_user.png",
    "rank": 103,
  };

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
                      index + 1, player['profilePic'], player['name'], player['level']);
                },
              ),
            ),
            const Divider(thickness: 2),
            _buildCurrentUserTile(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTile(int rank, String profilePic, String name, int level) {
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
        subtitle: Text("Level: $level"),
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

  Widget _buildCurrentUserTile() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(_currentUser['profilePic']),
          radius: 30,
        ),
        title: Text(
          _currentUser['name'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text("Level: ${_currentUser['level']}"),
        trailing: CircleAvatar(
          backgroundColor: Colors.blueGrey,
          child: Text(
            "${_currentUser['rank']}",
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
