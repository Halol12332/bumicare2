//this is inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constant_rewards.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with TickerProviderStateMixin {
  List<dynamic> claimedRewards = [];

  @override
  void initState() {
    super.initState();
    _loadClaimedRewards();
  }

  Future<void> _loadClaimedRewards() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final claimedRewardsJson = prefs.getString('claimedRewards_$username') ?? '[]';

    print('Claimed rewards for $username: $claimedRewardsJson');

    setState(() {
      claimedRewards = jsonDecode(claimedRewardsJson);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: Colors.green,
      ),
      body: claimedRewards.isEmpty
          ? const Center(
        child: Text(
          'No rewards claimed yet!',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: claimedRewards.length,
        itemBuilder: (context, index) {
          final reward = claimedRewards[index];
          final rewardName = rewards
              .firstWhere(
                  (r) => r['level'] == reward['level'],
              orElse: () => {'reward': 'Unknown Reward'})['reward'];
          final logoPath =
              rewardLogos[rewardName] ?? 'assets/default_logo.png';

          final claimedDate = DateTime.parse(reward['timestamp']);
          final expiryDate = claimedDate.add(const Duration(days: 7));
          final isExpired = DateTime.now().isAfter(expiryDate);
          final remainingTime = expiryDate.difference(DateTime.now());

          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Image.asset(
                logoPath,
                width: 40,
                height: 40,
              ),
              title: Text(rewardName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Claimed on: ${reward['timestamp']}'),
                  Text(
                    'Expires on: ${expiryDate.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(
                      color: isExpired ? Colors.red : Colors.green,
                    ),
                  ),
                  if (!isExpired)
                    LinearProgressIndicator(
                      value: remainingTime.inSeconds /
                          Duration(days: 7).inSeconds,
                      backgroundColor: Colors.grey[300],
                      color: Colors.green,
                    ),
                ],
              ),
              trailing: isExpired
                  ? const Text(
                'Expired',
                style: TextStyle(color: Colors.red),
              )
                  : reward['used'] == true
                  ? const Text(
                'Used',
                style: TextStyle(color: Colors.blue),
              )
                  : ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog(index);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('USE'),
              ),

            ),
          );
        },
      ),
    );
  }

  void _showConfirmationDialog(int index) {
    final reward = claimedRewards[index];
    final rewardName = rewards
        .firstWhere(
            (r) => r['level'] == reward['level'],
        orElse: () => {'reward': 'Unknown Reward'})['reward'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Use Reward'),
          content: Text(
              'Are you sure you want to use the reward: "$rewardName"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _useReward(index);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Use'),
            ),
          ],
        );
      },
    );
  }

  void _useReward(int index) async {
    final reward = claimedRewards[index];
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final claimedRewardsJson = prefs.getString('claimedRewards_$username') ?? '[]';
    final List<dynamic> claimedRewardsList = jsonDecode(claimedRewardsJson);

    // Tandai reward sebagai "used"
    claimedRewardsList[index]['used'] = true;

    await prefs.setString('claimedRewards_$username', jsonEncode(claimedRewards));

    setState(() {
      claimedRewards[index]['used'] = true; // Update lokal
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Used reward: ${reward['reward']}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }


  Future<void> _saveClaimedRewards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('claimedRewards', jsonEncode(claimedRewards));
  }
}
