import 'package:flutter/material.dart';
import 'screens/settings_screen.dart';

final List<String> _menuItems = <String>[
  'About',
  'Contact',
  'Settings',
  'Sign Out',
];

class _Drawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _Drawer({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: _menuItems
            .map(
              (item) => ListTile(
            onTap: () {
              if (item == 'Settings') {
                // Navigate to settings screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              }
              scaffoldKey.currentState?.openEndDrawer();
            },
            title: Text(item),
          ),
        ).toList(),
      ),
    );
  }
}


