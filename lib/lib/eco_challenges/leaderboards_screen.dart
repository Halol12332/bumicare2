import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Tab Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabButton('Level', 0),
              _buildTabButton('CO2 Saved', 1),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                // Parse Firestore data
                final users = snapshot.data!.docs.map((doc) {
                  return {
                    'nickname': doc['nickname'],
                    'avatar': doc['avatar'],
                    'level': doc['level'],
                    'CO2saved': doc['CO2saved'],
                    'achievements': doc['achievements'],
                  };
                }).toList();

                // Sort data based on the selected tab
                final sortedUsers = List<Map<String, dynamic>>.from(users)
                  ..sort((a, b) => selectedTab == 0
                      ? b['level'].compareTo(a['level']) // Sort by level
                      : b['CO2saved'].compareTo(a['CO2saved'])); // Sort by CO2 Saved

                return ListView.builder(
                  itemCount: sortedUsers.length,
                  itemBuilder: (context, index) {
                    final user = sortedUsers[index];
                    return _buildLeaderboardTile(user, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int tabIndex) {
    final isSelected = selectedTab == tabIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = tabIndex;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardTile(Map<String, dynamic> user, int index) {
    final bool isEven = index % 2 == 0;
    return Container(
      decoration: BoxDecoration(
        color: isEven ? Colors.green[50] : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user['avatar']),
          radius: 30,
        ),
        title: Text(
          user['nickname'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87, // Darker text color for better contrast
          ),
        ),
        subtitle: Text(
          selectedTab == 0
              ? 'Level: ${user['level']}'
              : 'CO2 Saved: ${user['CO2saved']} kg',
          style: TextStyle(
            color: Colors.black54, // Medium-dark color for subtitles
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.orange.shade700, // Darker orange for contrast
            ),
            Text(
              ' ${user['achievements']}',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
