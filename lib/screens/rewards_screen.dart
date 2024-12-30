import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constant_rewards.dart';

class RewardsScreen extends StatefulWidget {
  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  String userId = "";  // This will store the userId from Firestore
  Map<String, dynamic>? user;
  int userLevel = 1;  // Default level
  List<String> inventory = [];  // Track claimed rewards

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Get the currently logged-in user
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('No user is logged in.');
      }

      final String email = currentUser.email ?? '';  // Get the email of the current user
      print("Current User Email: $email");

      // Fetch the user document from Firestore using the email (not the userId)
      final userDoc = await FirebaseFirestore.instance.collection('users')
          .where('email', isEqualTo: email).limit(1).get();

      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first;
        setState(() {
          user = userData.data();
          userId = userData.id;  // Fetch the userId from Firestore document
          userLevel = user?['level'] ?? 1;
          inventory = List<String>.from(user?['inventory'] ?? []);
        });

        print("User ID: $userId");
        print("User Level: $userLevel");
        print("User Inventory: $inventory");
      } else {
        setState(() {
          user = {};  // Set an empty user to stop loading state
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found.')),
        );
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        user = {};  // Set an empty user to stop loading state
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }
  }

  Future<void> _claimReward(int level, String rewardText) async {
    if (inventory.contains(rewardText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reward already claimed!')),
      );
      return;
    }

    if (user?['usedRewards']?.contains(rewardText) == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reward already used!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'inventory': FieldValue.arrayUnion([rewardText]), // Add reward to inventory
      });

      setState(() {
        inventory.add(rewardText); // Update local inventory
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Claimed reward: $rewardText')),
      );
    } catch (e) {
      print("Error claiming reward: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to claim reward. Please try again.')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView.builder(
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              final level = reward['level'];
              final rewardText = reward['reward'];
              final logoPath = rewardLogos[rewardText] ?? '';
              final isClaimable = userLevel >= level &&
                  !inventory.contains(rewardText) &&
                  !(user?['usedRewards']?.contains(rewardText) == true);



              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Logo
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: logoPath.isNotEmpty
                              ? Image.asset(
                            logoPath,
                            fit: BoxFit.contain,
                          )
                              : const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      // Reward Details
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Level $level',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                rewardText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Claim Button
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              backgroundColor: isClaimable ? Colors.green : Colors.grey,
                            ),
                            onPressed: isClaimable
                                ? () => _claimReward(level, rewardText)
                                : null,
                            child: const Text('Claim'),
                          ),

                        ),
                      ),

                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
