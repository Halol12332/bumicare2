//this is eco_track_screen.dart
import 'package:flutter/material.dart';

class EcoTrackScreen extends StatefulWidget {
  @override
  _EcoTrackScreenState createState() => _EcoTrackScreenState();
}

class _EcoTrackScreenState extends State<EcoTrackScreen> {
  int totalXP = 0;
  double totalCO2Saved = 0.0;

  void completeChallenge(double co2Saved) {
    setState(() {
      totalXP += 10; // Setiap tantangan memberikan 10 XP
      totalCO2Saved += co2Saved;
    });
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                )
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
                    "Berapa banyak barang reusable yang Anda gunakan hari ini?",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: "Botol Minum"),
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
                          decoration: InputDecoration(labelText: "Tas Belanja"),
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
                    decoration: InputDecoration(labelText: "Wadah Makanan"),
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
                        SnackBar(content: Text("CO2 yang dihemat: ${co2Saved.toStringAsFixed(2)} kg")),
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

  // List untuk menyimpan data perangkat dan durasi
  List<Map<String, dynamic>> devices = [
    {"type": "Lampu", "duration": 0},
  ];

  // Faktor emisi CO2 per jenis perangkat
  final Map<String, double> co2Factors = {
    "Lampu": 0.02,
    "Kipas": 0.03,
    "AC": 0.2,
    "Laptop": 0.1,
  };

  // Menghitung total CO2 yang dihemat
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
                    "Pilih perangkat yang Anda matikan dan durasinya:",
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
                                  devices[entry.key]["type"] = value ?? "Lampu";
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
                                labelText: "Jenis Perangkat",
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "Durasi (jam)",
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
                        devices.add({"type": "Lampu", "duration": 0});
                      });
                    },
                    child: Text("Tambah Perangkat"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      double co2Saved = calculateCO2Saved();
                      widget.onComplete(co2Saved);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "CO2 yang dihemat: ${co2Saved.toStringAsFixed(2)} kg",
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

  // List untuk menyimpan data perjalanan (mode transportasi dan jarak)
  List<Map<String, dynamic>> trips = [
    {"mode": "Berjalan Kaki", "distance": 0},
  ];

  // Emisi CO2 per kilometer untuk setiap mode transportasi
  final Map<String, double> co2Factors = {
    "Berjalan Kaki": 0.0,
    "Sepeda": 0.0,
    "Transportasi Umum": 0.05,
    "Kendaraan Pribadi": 0.12,
  };

  // Menghitung total CO2 yang dihasilkan
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
                    "Masukkan mode transportasi Anda dan jarak perjalanan:",
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
                                  trips[entry.key]["mode"] = value ?? "Berjalan Kaki";
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
                                labelText: "Mode Transportasi",
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "Jarak (km)",
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
                        trips.add({"mode": "Berjalan Kaki", "distance": 0});
                      });
                    },
                    child: Text("Tambah Perjalanan"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      double co2Emissions = calculateCO2Emissions();
                      widget.onComplete(co2Emissions);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "CO2 yang dihasilkan: ${co2Emissions.toStringAsFixed(2)} kg",
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
    // Menghitung penghematan CO2
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
                    "Berapa banyak makanan nabati dan makanan berbasis daging yang Anda makan hari ini?",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Makanan Nabati (porsi)"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        plantBasedMeals = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Makanan Daging (porsi)"),
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
                          ? "CO2 yang dihemat: ${co2Saved.toStringAsFixed(2)} kg"
                          : "CO2 yang dihasilkan lebih banyak: ${(-co2Saved).toStringAsFixed(2)} kg";

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
    // Perhitungan penghematan CO2 berdasarkan jenis material
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
                    "Berapa banyak sampah yang Anda daur ulang hari ini?",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Plastik (kg)"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        plasticWeight = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Kertas (kg)"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        paperWeight = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Logam (kg)"),
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
                              "CO2 yang dihemat: ${co2Saved.toStringAsFixed(2)} kg"),
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
