//this is eco_challenges.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EcoTrackScreen extends StatefulWidget {
  @override
  _EcoTrackScreenState createState() => _EcoTrackScreenState();
}

class _EcoTrackScreenState extends State<EcoTrackScreen> {
  int totalXP = 0;
  double totalCO2Saved = 0.0;
  int currentLevel = 1;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data saat halaman dibuka
  }

  Future<void> _fetchUserData() async {
    try {
      // Ambil email user dari SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('username'); // Pastikan email disimpan sebelumnya

      if (email == null) {
        throw "User email not found in SharedPreferences";
      }

      // Ambil data user dari Firestore berdasarkan email
      DocumentSnapshot userSnapshot =
      await _firestore.collection('users').doc(email).get();

      // Validasi apakah data user ditemukan
      if (!userSnapshot.exists) {
        throw "User data not found in Firestore";
      }

      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      // Perbarui state dengan data user
      setState(() {
        totalXP = userData['exp'] ?? 0;
        currentLevel = userData['level'] ?? 1;
        totalCO2Saved = userData['CO2saved'] ?? 0.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> completeChallenge(double co2Saved) async {
    try {
      // Ambil email user dari SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('username'); // Pastikan email disimpan sebelumnya

      if (email == null) {
        throw "User email not found in SharedPreferences";
      }

      // Ambil data user dari Firestore berdasarkan email
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(email).get();

      // Validasi apakah data user ditemukan
      if (!userSnapshot.exists) {
        throw "User data not found in Firestore";
      }

      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      // Ambil XP, level, dan CO2 yang tersimpan saat ini
      int currentXP = userData['exp'] ?? 0;
      int currentLevel = userData['level'] ?? 1;
      double currentCO2Saved = userData['CO2saved'] ?? 0.0;

      // Tambahkan XP dan CO2 yang baru
      int newXP = currentXP + 10; // XP dari challenge
      double newCO2Saved = currentCO2Saved + co2Saved;

      // Hitung level baru jika XP lebih dari 100
      while (newXP >= 100) {
        newXP -= 100;
        currentLevel += 1;
      }

      // Update Firestore dengan data baru
      await _firestore.collection('users').doc(email).update({
        'exp': newXP,
        'level': currentLevel,
        'CO2saved': newCO2Saved,
      });

      // Update UI lokal
      setState(() {
        totalXP = newXP;
        totalCO2Saved = newCO2Saved;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Challenge completed! CO2 saved: ${co2Saved.toStringAsFixed(2)} kg"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eco Track Challenges'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level: $currentLevel',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total XP: $totalXP',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'CO2 Saved: ${totalCO2Saved.toStringAsFixed(2)} kg',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                ExpandableReusableChallenge(
                  onComplete: (double co2Saved) => completeChallenge(co2Saved),
                ),
                ExpandableEnergySaverChallenge(
                  onComplete: (double co2Saved) => completeChallenge(co2Saved),
                ),
                ExpandableTravelChallenge(
                  onComplete: (double co2Saved) => completeChallenge(co2Saved),
                ),
                ExpandableMeatlessMealChallenge(
                  onComplete: (double co2Saved) => completeChallenge(co2Saved),
                ),
                ExpandableWasteSegregationChallenge(
                  onComplete: (double co2Saved) => completeChallenge(co2Saved),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableReusableChallenge extends StatefulWidget {
  final Function(double) onComplete;

  const ExpandableReusableChallenge({required this.onComplete});

  @override
  _ExpandableReusableChallengeState createState() =>
      _ExpandableReusableChallengeState();
}
class _ExpandableReusableChallengeState extends State<ExpandableReusableChallenge> {
  bool isExpanded = false;
  int bottles = 0;
  int bags = 0;
  int containers = 0;

  double calculateCO2Saved() {
    return (bottles * 0.1) + (bags * 0.05) + (containers * 0.2);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Reusable Challenge",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How many reusable items did you use today?",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: "Water Bottles"),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              bottles = int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: "Shopping Bags"),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              bags = int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Food Containers"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        containers = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      double co2Saved = calculateCO2Saved();
                      widget.onComplete(co2Saved);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("CO2 saved: ${co2Saved.toStringAsFixed(2)} kg")),
                      );
                    },
                    child: Text("Complete Challenge"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ExpandableEnergySaverChallenge extends StatefulWidget {
  final Function(double) onComplete;

  const ExpandableEnergySaverChallenge({required this.onComplete});

  @override
  _ExpandableEnergySaverChallengeState createState() =>
      _ExpandableEnergySaverChallengeState();
}
class _ExpandableEnergySaverChallengeState extends State<ExpandableEnergySaverChallenge> {
  bool isExpanded = false;

  // List to store device data and duration
  List<Map<String, dynamic>> devices = [
    {"type": "Lamp", "duration": 0},
  ];

  // CO2 emission factor for each device type
  final Map<String, double> co2Factors = {
    "Lamp": 0.02,
    "Fan": 0.03,
    "AC": 0.2,
    "Laptop": 0.1,
  };

  // Calculate the total CO2 saved
  double calculateCO2Saved() {
    double totalCO2 = 0.0;
    for (var device in devices) {
      totalCO2 += (co2Factors[device["type"]] ?? 0.0) * device["duration"];
    }
    return totalCO2;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Energy Saver Challenge",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose the devices you turned off and their duration:",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: devices
                        .asMap()
                        .entries
                        .map(
                          (entry) => Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: entry.value["type"],
                              onChanged: (value) {
                                setState(() {
                                  devices[entry.key]["type"] = value ?? "Lamp";
                                });
                              },
                              items: co2Factors.keys
                                  .map(
                                    (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                                  .toList(),
                              decoration: InputDecoration(
                                labelText: "Device Type",
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "Duration (hours)",
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  devices[entry.key]["duration"] =
                                      int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                devices.removeAt(entry.key);
                              });
                            },
                          ),
                        ],
                      ),
                    )
                        .toList(),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        devices.add({"type": "Lamp", "duration": 0});
                      });
                    },
                    child: Text("Add Device"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      double co2Saved = calculateCO2Saved();
                      widget.onComplete(co2Saved);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "CO2 saved: ${co2Saved.toStringAsFixed(2)} kg",
                          ),
                        ),
                      );
                    },
                    child: Text("Complete Challenge"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ExpandableTravelChallenge extends StatefulWidget {
  final Function(double) onComplete;

  const ExpandableTravelChallenge({required this.onComplete});

  @override
  _ExpandableTravelChallengeState createState() =>
      _ExpandableTravelChallengeState();
}
class _ExpandableTravelChallengeState extends State<ExpandableTravelChallenge> {
  bool isExpanded = false;

  // List to store trip data (transport mode and distance)
  List<Map<String, dynamic>> trips = [
    {"mode": "Walking", "distance": 0},
  ];

  // CO2 emissions per kilometer for each transport mode
  final Map<String, double> co2Factors = {
    "Walking": 0.0,
    "Bicycle": 0.0,
    "Public Transport": 0.05,
    "Private Vehicle": 0.12,
  };

  // Calculate total CO2 emissions
  double calculateCO2Emissions() {
    double totalCO2 = 0.0;
    for (var trip in trips) {
      totalCO2 += (co2Factors[trip["mode"]] ?? 0.0) * trip["distance"];
    }
    return totalCO2;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "How Did You Travel Today?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter your transport mode and travel distance:",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: trips
                        .asMap()
                        .entries
                        .map(
                          (entry) => Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: entry.value["mode"],
                              onChanged: (value) {
                                setState(() {
                                  trips[entry.key]["mode"] = value ?? "Walking";
                                });
                              },
                              items: co2Factors.keys
                                  .map(
                                    (mode) => DropdownMenuItem(
                                  value: mode,
                                  child: Text(mode),
                                ),
                              )
                                  .toList(),
                              decoration: InputDecoration(
                                labelText: "Transport Mode",
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "Distance (km)",
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  trips[entry.key]["distance"] =
                                      double.tryParse(value) ?? 0.0;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                trips.removeAt(entry.key);
                              });
                            },
                          ),
                        ],
                      ),
                    )
                        .toList(),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        trips.add({"mode": "Walking", "distance": 0});
                      });
                    },
                    child: Text("Add Trip"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      double co2Emissions = calculateCO2Emissions();
                      widget.onComplete(co2Emissions);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "CO2 emitted: ${co2Emissions.toStringAsFixed(2)} kg",
                          ),
                        ),
                      );
                    },
                    child: Text("Complete Challenge"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ExpandableMeatlessMealChallenge extends StatefulWidget {
  final Function(double) onComplete;

  const ExpandableMeatlessMealChallenge({required this.onComplete});

  @override
  _ExpandableMeatlessMealChallengeState createState() =>
      _ExpandableMeatlessMealChallengeState();
}
class _ExpandableMeatlessMealChallengeState extends State<ExpandableMeatlessMealChallenge> {
  bool isExpanded = false;
  int plantBasedMeals = 0;
  int meatMeals = 0;

  double calculateCO2Saved() {
    // Calculate CO2 savings
    return (meatMeals * 2.5) - (plantBasedMeals * 0.3);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Meatless Meal Challenge",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How many plant-based and meat-based meals did you eat today?",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Plant-Based Meals (servings)"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        plantBasedMeals = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Meat Meals (servings)"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        meatMeals = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      double co2Saved = calculateCO2Saved();
                      String message = co2Saved >= 0
                          ? "CO2 saved: ${co2Saved.toStringAsFixed(2)} kg"
                          : "More CO2 emitted: ${(-co2Saved).toStringAsFixed(2)} kg";

                      widget.onComplete(co2Saved);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    },
                    child: Text("Complete Challenge"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ExpandableWasteSegregationChallenge extends StatefulWidget {
  final Function(double) onComplete;

  const ExpandableWasteSegregationChallenge({required this.onComplete});

  @override
  _ExpandableWasteSegregationChallengeState createState() =>
      _ExpandableWasteSegregationChallengeState();
}
class _ExpandableWasteSegregationChallengeState extends State<ExpandableWasteSegregationChallenge> {
  bool isExpanded = false;
  double plasticWeight = 0.0;
  double paperWeight = 0.0;
  double metalWeight = 0.0;

  double calculateCO2Saved() {
    // CO2 savings calculation based on material type
    return (plasticWeight * 1.5) + (paperWeight * 0.8) + (metalWeight * 2.0);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Waste Segregation Challenge",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How much waste did you recycle today?",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Plastic (kg)"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        plasticWeight = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Paper (kg)"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        paperWeight = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Metal (kg)"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        metalWeight = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      double co2Saved = calculateCO2Saved();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "CO2 saved: ${co2Saved.toStringAsFixed(2)} kg"),
                        ),
                      );
                      widget.onComplete(co2Saved);
                    },
                    child: Text("Complete Challenge"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
