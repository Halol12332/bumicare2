// challenges_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final List<bool> _checkedItems = List.generate(8, (index) => false);

  final List<Map<String, dynamic>> challenges = [
    {"title": "Plant a tree", "exp": 50},
    {"title": "Reduce plastic use", "exp": 30},
    {"title": "Recycle old items", "exp": 40},
    {"title": "Bike to work", "exp": 60},
    {"title": "Save energy at home", "exp": 20},
    {"title": "Start a compost", "exp": 50},
    {"title": "Join a beach cleanup", "exp": 70},
    {"title": "Spread awareness", "exp": 25},
  ];

  int totalExp = 0;

  Future<void> _updateUserExp(int exp) async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString('accounts') ?? '[]';
    final List<dynamic> accounts = jsonDecode(accountsJson);
    final username = prefs.getString('username') ?? '';
    int previousLevel = 0;
    int newLevel = 0;

    for (var account in accounts) {
      if (account['nickname'] == username) {
        int currentXP = account['currentXP'] ?? 0;
        previousLevel = account['level'] ?? 1; // Track the old level
        currentXP += exp;

        // Update level and XP
        newLevel = previousLevel;
        while (currentXP >= 100) {
          currentXP -= 100;
          newLevel++;
        }

        account['currentXP'] = currentXP;
        account['level'] = newLevel;
        break;
      }
    }

    await prefs.setString('accounts', jsonEncode(accounts));

    // Check if the level has changed
    if (newLevel > previousLevel) {
      _showLevelUpDialog(newLevel);
    }
  }

  void _showLevelUpDialog(int level) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Congratulations!"),
          content: Text("You leveled up to level $level!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Challenges"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Total XP Earned: $totalExp",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 40),
          const Text(
            "Upload your challenge media",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _UploadBox(),
          const SizedBox(height: 30),
          const Text(
            "Complete the challenges below:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  value: _checkedItems[index],
                  onChanged: (bool? value) {
                    setState(() {
                      _checkedItems[index] = value ?? false;
                      totalExp = _calculateTotalExp();
                    });
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(challenges[index]["title"]),
                      Text("+${challenges[index]["exp"]} XP",
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.green,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final int earnedExp = totalExp; // Store the correct XP amount
              await _updateUserExp(earnedExp);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Submission Complete"),
                  content: Text("You earned a total of $earnedExp XP!"), // Use the stored XP
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
              setState(() {
                totalExp = 0;
                _checkedItems.fillRange(0, _checkedItems.length, false);
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Submit",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  int _calculateTotalExp() {
    int exp = 0;
    for (int i = 0; i < _checkedItems.length; i++) {
      if (_checkedItems[i]) {
        exp += challenges[i]["exp"] as int;
      }
    }
    return exp;
  }
}

class _UploadBox extends StatefulWidget {
  @override
  _UploadBoxState createState() => _UploadBoxState();
}

class _UploadBoxState extends State<_UploadBox> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width * 0.5,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: _selectedFile == null
            ? ElevatedButton(
          onPressed: _pickFile,
          child: const Text('Upload Image/Video'),
        )
            : Image.file(_selectedFile!, fit: BoxFit.cover),
      ),
    );
  }
}
