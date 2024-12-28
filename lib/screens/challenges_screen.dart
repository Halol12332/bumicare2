//challenges_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final List<bool> _checkedItems = List.generate(8, (index) => false);

  final List<String> challenges = [
    "Plant a tree",
    "Reduce plastic use",
    "Recycle old items",
    "Bike to work",
    "Save energy at home",
    "Start a compost",
    "Join a beach cleanup",
    "Spread awareness"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Challenges"),
      ),
      body: Column(
        children: [
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
                    });
                  },
                  title: Text(challenges[index]),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.green,
                );
              },
            ),
          ),
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