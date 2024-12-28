//community_screen.dart
import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Community")),
      body: const Center(
        child: Text("Engage with the community and share ideas!"),
      ),
    );
  }
}