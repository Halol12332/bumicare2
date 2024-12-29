import 'package:flutter/material.dart';
import 'package:bumicare2/profile_icon.dart';
import 'package:bumicare2/screens/rewards_screen.dart';
import 'challenges_screen.dart';
import 'community_screen.dart';
import 'eco_track_screen.dart';
import 'leaderboards_screen.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width > 800;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        elevation: 0,
        titleSpacing: 0,
        leading: isLargeScreen
            ? null
            : IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "BumiCare",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              if (isLargeScreen) Expanded(child: _navBarItems())
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(child: ProfileIcon()),
          )
        ],
      ),
      drawer: isLargeScreen ? null : _drawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _dailyTipsSection(),
              const SizedBox(height: 20),
              _motivationSection(),
              const SizedBox(height: 20),
              _engagementSection(context),
              const SizedBox(height: 20),
              _actionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dailyTipsSection() {
    return Card(
      color: Colors.green[700],
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🌿 Daily Eco Tip",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "Matikan perangkat yang tidak digunakan untuk menghemat energi. Ini langkah kecil untuk Anda, tapi besar untuk bumi!",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _motivationSection() {
    return const Card(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "💡 Today's Motivation",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            SizedBox(height: 10),
            Text(
              "“Ancaman terbesar bagi planet ini adalah keyakinan bahwa orang lain yang akan menyelamatkannya.” – Robert Swan",
              style: TextStyle(
                  fontSize: 16, color: Colors.white, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _engagementSection(BuildContext context) {
    return Card(
      color: Colors.green[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🌍 Community Forum",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              "Bergabunglah dalam diskusi! Bagikan pemikiran dan ide ramah lingkungan Anda dengan komunitas.",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CommunityScreen()),
                );
              },
              child: const Text("Kunjungi Forum", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Column(
      children: [
        _buildButton(context, "Challenges", Colors.green[700]!, const ChallengesScreen()),
        _buildButton(context, "Leaderboards", Colors.green[900]!, const LeaderboardsScreen()),
        _buildButton(context, "EcoTrack", Colors.black, EcoTrackScreen()),
        _buildButton(context, "Rewards", Colors.green, RewardsScreen()),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String title, Color color, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 60),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _drawer() => Drawer(
    child: ListView(
      children: _menuItems
          .map((item) => ListTile(
        onTap: () {
          _scaffoldKey.currentState?.openEndDrawer();
        },
        title: Text(
          item,
          style: const TextStyle(color: Colors.green),
        ),
      ))
          .toList(),
    ),
  );

  Widget _navBarItems() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: _menuItems
        .map(
          (item) => InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 24.0, horizontal: 16),
          child: Text(
            item,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    )
        .toList(),
  );
}

final List<String> _menuItems = <String>[
  'Tentang',
  'Kontak',
  'Pengaturan',
  'Keluar',
];
