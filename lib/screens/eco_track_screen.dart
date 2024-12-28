//eco_track_screen.dart
import 'package:flutter/material.dart';

class EcoTrackScreen extends StatelessWidget {
  const EcoTrackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EcoTrack")),
      body: const Center(
        child: Text("Track your sustainability progress here!"),
      ),
    );
  }
}