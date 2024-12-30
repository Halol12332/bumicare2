import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constant_rewards.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<dynamic> inventory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  // Load user inventory from Firestore
  Future<void> _loadInventory() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user is logged in.');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.email)
          .get();

      if (!userDoc.exists) throw Exception('User document does not exist.');

      final userData = userDoc.data();
      final List<dynamic> userInventory = userData?['inventory'] ?? [];

      setState(() {
        inventory = userInventory;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading inventory: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading inventory: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Use a reward and update Firestore
  Future<void> _useReward(String rewardName) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user is logged in.');

      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.email);

      final userDoc = await userDocRef.get();
      if (!userDoc.exists) throw Exception('User document does not exist.');

      List<dynamic> updatedInventory = List.from(userDoc.data()?['inventory'] ?? []);
      updatedInventory.remove(rewardName);

      List<dynamic> updatedUsedRewards = List.from(userDoc.data()?['usedRewards'] ?? []);
      updatedUsedRewards.add(rewardName);

      await userDocRef.update({
        'inventory': updatedInventory,
        'usedRewards': updatedUsedRewards,
      });

      setState(() {
        inventory = updatedInventory;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reward '$rewardName' used successfully!")),
      );
    } catch (e) {
      print("Error using reward: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error using reward: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Inventory'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : inventory.isEmpty
          ? const Center(
        child: Text(
          'Your inventory is empty!',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: inventory.length,
        itemBuilder: (context, index) {
          final rewardName = inventory[index];
          final rewardLogo = rewardLogos[rewardName] ?? '../assets/default_logo.png';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      rewardLogo,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rewardName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.black45,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _useReward(rewardName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Use'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
