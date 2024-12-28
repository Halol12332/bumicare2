import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdditionalInfoScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AdditionalInfoScreen({Key? key, this.userData}) : super(key: key);

  @override
  _AdditionalInfoScreenState createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  final _nicknameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _birthDateController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveAdditionalInfo(BuildContext context) async {
    final nickname = _nicknameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final birthDate = _birthDateController.text.trim();

    if (nickname.isEmpty || phoneNumber.isEmpty || birthDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString('accounts') ?? '[]';
    final List<dynamic> accounts = jsonDecode(accountsJson);

    accounts.add({
      'email': widget.userData?['email'],
      'fullName': widget.userData?['fullName'],
      'nickname': nickname,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate,
      'profilePicture': _selectedImage?.path ?? widget.userData?['profilePicture'],
    });

    await prefs.setString('accounts', jsonEncode(accounts));
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', nickname);

    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile sign_up_screen.dart'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (widget.userData?['profilePicture'] != null
                    ? NetworkImage(widget.userData?['profilePicture'])
                    : null) as ImageProvider?,
                child: _selectedImage == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: 'Nickname'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _birthDateController,
              decoration: const InputDecoration(labelText: 'Date of Birth'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveAdditionalInfo(context),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
