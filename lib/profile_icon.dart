//profile_icon.dart
import 'package:flutter/material.dart';
import 'screens/profile_screen.dart'; // Import the profile screen
import 'screens/login_screen.dart'; // Import the login screen

enum Menu { itemOne, itemTwo}

class ProfileIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
      icon: const Icon(Icons.person),
      offset: const Offset(0, 40),
      onSelected: (Menu item) {
        if (item == Menu.itemOne) {
          // Navigate to ProfileScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserProfileScreen()),
          );
        } else if (item == Menu.itemTwo) {
          // Navigate to LoginScreen (for sign out)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false, // Clear all routes after sign out
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
        const PopupMenuItem<Menu>(
          value: Menu.itemOne,
          child: Text('Account'),
        ),
        const PopupMenuItem<Menu>(
          value: Menu.itemTwo,
          child: Text('Sign Out'),
        ),
      ],
    );
  }
}
