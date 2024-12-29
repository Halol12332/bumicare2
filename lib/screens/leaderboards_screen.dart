//this is leaderboards_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

class LeaderboardsScreen extends StatelessWidget {
  const LeaderboardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulasi data pemain
    final random = Random();
    final allPlayers = List.generate(
      200,
          (index) => Player(
        'Player ${index + 1}',
        random.nextInt(120) + 1, // Level antara 1 hingga 120
        '../assets/avatar.png',
      ),
    );

    // Tambahkan data pengguna
    final currentUser = Player('You', 4, '../assets/avatar_user.png');
    allPlayers.add(currentUser);

    // Hitung peringkat pengguna
    final calculator = UserRankCalculator(allPlayers, currentUser);
    final userRank = calculator.calculateRank();

    // Top 10 pemain
    final topPlayers = allPlayers.sublist(0, 10);

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
                itemCount: topPlayers.length,
                itemBuilder: (context, index) {
                  final player = topPlayers[index];
                  return _buildLeaderboardTile(
                      index + 1, player.profilePic, player.name, player.level);
                },
              ),
            ),
            const Divider(thickness: 2),
            _buildCurrentUserTile(userRank, currentUser),
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

  Widget _buildCurrentUserTile(int rank, Player currentUser) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(currentUser.profilePic),
          radius: 30,
        ),
        title: Text(
          currentUser.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text("Level: ${currentUser.level}"),
        trailing: CircleAvatar(
          backgroundColor: Colors.blueGrey,
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

class Player {
  final String name;
  final int level;
  final String profilePic;

  Player(this.name, this.level, this.profilePic);
}

class UserRankCalculator {
  final List<Player> allPlayers;
  final Player currentUser;

  UserRankCalculator(this.allPlayers, this.currentUser);

  int calculateRank() {
    // Urutkan pemain berdasarkan level (descending)
    allPlayers.sort((a, b) => b.level.compareTo(a.level));

    // Cari indeks pengguna saat ini
    for (int i = 0; i < allPlayers.length; i++) {
      if (allPlayers[i].name == currentUser.name) {
        return i + 1; // Peringkat dimulai dari 1
      }
    }

    // Jika pengguna tidak ditemukan
    return -1;
  }
}
