import 'package:flutter/material.dart';
import 'package:bumicare2/main/profile_icon.dart';
import 'package:bumicare2/rewards/rewards_screen.dart';
import '../accounts_handling/auth_service.dart';
import '../main/about_screen.dart';
import '../main/contact_screen.dart';
import '../screens/community_screen.dart';
import '../eco_challenges/eco_challenges.dart';
import '../eco_challenges/leaderboards_screen.dart';
import '../screens/inventory_screen.dart';
import 'settings_screen.dart';


class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();

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
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              if (isLargeScreen) Expanded(child: _navBarItems(context))
            ],
          ),
        ),
        actions: [
          // Inventory Button
          IconButton(
            icon: const Icon(Icons.inventory, color: Colors.white),  // You can replace this with any icon you prefer
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InventoryScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(child: ProfileIcon()),
          )
        ],
      ),

      drawer: isLargeScreen ? null : _drawer(context),
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
              "Turn off unused devices to save energy. It's a small step for you, but a big one for the planet!",
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
              "“The greatest threat to our planet is the belief that someone else will save it.” – Robert Swan",
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
              "Join the discussion! Share your eco-friendly thoughts and ideas with the community.",
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
              child: const Text("Visit Forum", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Column(
      children: [
        _buildButton(context, "Eco-Challenges", Colors.black, EcoTrackScreen()),
        _buildButton(context, "Leaderboards", Colors.green[900]!, LeaderboardScreen()),
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

  Widget _drawer(BuildContext context) => Drawer(
    child: ListView(
      children: _menuItems
          .map((item) => ListTile(
        onTap: () {
          _onMenuItemTap(context, item);
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

  Widget _navBarItems(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: _menuItems
        .map(
          (item) => InkWell(
        onTap: () => _onMenuItemTap(context, item),
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

  Future<void> _onMenuItemTap(BuildContext context, String item) async {
    switch (item) {
      case 'About':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutScreen()),
        );
        break;
      case 'Contact':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ContactScreen()),
        );
        break;
      case 'Settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 'Logout':
      // Confirm logout
        final confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Log Out'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Log Out'),
                ),
              ],
            );
          },
        );

        if (confirm == true) {
          await _authService.signOut(); // Firebase and Google logout
          await logout(context); // Clear preferences and navigate to login
        }
        break;
    }
  }
}



// Drawer Menu Items
final List<String> _menuItems = <String>[
  'About',
  'Contact',
  'Settings',
  'Logout',
];
