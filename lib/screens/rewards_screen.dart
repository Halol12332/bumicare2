//this is rewards_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant_rewards.dart';

class RewardsScreen extends StatefulWidget {
  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  Map<String, dynamic>? user;
  int userLevel = 1; // Default level
  List<int> _claimedRewards = []; // Track claimed rewards

  @override
  void initState() {
    super.initState();
    // Pastikan _getUserInfo dipanggil sebelum _getUserLevel
    _getUserInfo().then((_) => _getUserLevel());
  }

  Future<void> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      setState(() {
        user = jsonDecode(userJson);
      });
    }
  }

  Future<void> _getUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString('accounts') ?? '[]';
    final List<dynamic> accounts = jsonDecode(accountsJson);
    final username = prefs.getString('username') ?? '';

    // Find the account for the logged-in user
    final userAccount = accounts.firstWhere(
          (account) => account['nickname'] == username,
      orElse: () => null,
    );

    // Retrieve user level and claimed rewards
    final claimedRewardsJson = prefs.getString('claimedRewards_$username') ?? '[]';

    setState(() {
      userLevel = userAccount?['level'] ?? 1; // Update userLevel from stored data
      _claimedRewards = jsonDecode(claimedRewardsJson).map<int>((e) => e as int).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView.builder(
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              final level = reward['level'];
              final rewardText = reward['reward'];
              final logoPath = rewardLogos[rewardText] ?? '';
              final isClaimable = userLevel >= level && !_claimedRewards.contains(level);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 130, // Adjusted for logo and reward text
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
                      // Logo (20% of width)
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
                      // Reward Text (60% of width)
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
                      // Claim Button (20% of width)
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
                              backgroundColor:
                              isClaimable ? Colors.green : Colors.grey,
                            ),
                            onPressed: isClaimable
                                ? () async {
                              final prefs = await SharedPreferences.getInstance();
                              final username = prefs.getString('username') ?? '';
                              final claimedRewardsJson = prefs.getString('claimedRewards_$username') ?? '[]';
                              final List<dynamic> claimedRewards = jsonDecode(claimedRewardsJson);

                              // Pastikan reward tidak diklaim dua kali
                              if (!claimedRewards.any((reward) => reward['level'] == level)) {
                                claimedRewards.add({
                                  'level': level,
                                  'timestamp': DateTime.now().toString(),
                                  'used': false,
                                });

                                await prefs.setString('claimedRewards_$username', jsonEncode(claimedRewards));

                                setState(() {
                                  _claimedRewards.add(level);
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Claimed reward: $rewardText'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reward already claimed!'),
                                  ),
                                );
                              }
                            }
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
