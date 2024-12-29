//challenges_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../ecotrack_calculate.dart';


class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  int totalExp = 0;
  int totalCO2Saved = 0;
  int totalItemsRecycled = 0;

  final List<bool> _checkedItems = List.generate(8, (index) => false);

  Future<void> _updateUserExpAndStats(int exp, int co2Saved, int itemsRecycled) async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString('accounts') ?? '[]';
    final List<dynamic> accounts = jsonDecode(accountsJson);
    final username = prefs.getString('username') ?? '';
    int previousLevel = 0;
    int newLevel = 0;

    for (var account in accounts) {
      if (account['nickname'] == username) {
        int currentXP = account['currentXP'] ?? 0;
        int totalCO2Saved = account['co2Saved'] ?? 0;
        int totalItemsRecycled = account['itemsRecycled'] ?? 0;

        previousLevel = account['level'] ?? 1;
        currentXP += exp;
        totalCO2Saved += co2Saved;
        totalItemsRecycled += itemsRecycled;

        newLevel = previousLevel;
        while (currentXP >= 100) {
          currentXP -= 100;
          newLevel++;
        }

        account['currentXP'] = currentXP;
        account['level'] = newLevel;
        account['co2Saved'] = totalCO2Saved;
        account['itemsRecycled'] = totalItemsRecycled;
        break;
      }
    }

    await prefs.setString('accounts', jsonEncode(accounts));

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

  int _calculateTotalExp() {
    int exp = 0;
    for (int i = 0; i < _checkedItems.length; i++) {
      if (_checkedItems[i]) {
        exp += challenges[i]["exp"] as int;
      }
    }
    return exp;
  }

  int _calculateCO2Saved() {
    int co2Saved = 0;
    for (int i = 0; i < _checkedItems.length; i++) {
      if (_checkedItems[i]) {
        co2Saved += challenges[i]["co2_saved"] as int;
      }
    }
    return co2Saved;
  }

  int _calculateItemsRecycled() {
    int itemsRecycled = 0;
    for (int i = 0; i < _checkedItems.length; i++) {
      if (_checkedItems[i]) {
        itemsRecycled += challenges[i]["items_recycled"] as int;
      }
    }
    return itemsRecycled;
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
          Text(
            "CO₂ Saved: $totalCO2Saved kg",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          Text(
            "Items Recycled: $totalItemsRecycled",
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
                      totalCO2Saved = _calculateCO2Saved();
                      totalItemsRecycled = _calculateItemsRecycled();
                    });
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(challenges[index]["title"]),
                      Text(
                        "+${challenges[index]["exp"]} XP",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
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
              final int earnedExp = totalExp;
              final int co2Saved = totalCO2Saved;
              final int itemsRecycled = totalItemsRecycled;

              await _updateUserExpAndStats(earnedExp, co2Saved, itemsRecycled);

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Submission Complete"),
                  content: Text(
                    "You earned $earnedExp XP!\n"
                        "CO₂ Saved: $co2Saved kg\n"
                        "Items Recycled: $itemsRecycled",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context, { // Return the result
                          'co2Saved': co2Saved,
                          'itemsRecycled': itemsRecycled,
                        });
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );

              setState(() {
                totalExp = 0;
                totalCO2Saved = 0;
                totalItemsRecycled = 0;
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
