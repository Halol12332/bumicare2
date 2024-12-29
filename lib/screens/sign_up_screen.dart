import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InteractiveSignUpScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  InteractiveSignUpScreen({required this.userData});

  @override
  _InteractiveSignUpScreenState createState() =>
      _InteractiveSignUpScreenState();
}

class _InteractiveSignUpScreenState extends State<InteractiveSignUpScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  File? _selectedImage;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    if (widget.userData.isNotEmpty) {
      _nicknameController.text = widget.userData['fullName'] ?? '';
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneNumberController.dispose();
    _birthDateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _onSignUpPressed() async {
    if (_nicknameController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _birthDateController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields!')),
      );
    } else {
      final prefs = await SharedPreferences.getInstance();

      // Retrieve stored accounts
      final accountsJson = prefs.getString('accounts') ?? '[]';
      final List<dynamic> accounts = jsonDecode(accountsJson);

      // Check if the account already exists
      final existingAccount = accounts.firstWhere(
            (account) => account['email'] == widget.userData['email'],
        orElse: () => null,
      );

      if (existingAccount != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account already exists!')),
        );
      } else {
        // Add new account details
        final newAccount = {
          'nickname': _nicknameController.text,
          'phoneNumber': _phoneNumberController.text,
          'birthDate': _birthDateController.text,
          'email': widget.userData['email'], // Save email for verification
          'profileImage': _selectedImage!.path, // Save the image path
        };

        accounts.add(newAccount);

        // Save updated accounts to SharedPreferences
        await prefs.setString('accounts', jsonEncode(accounts));
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', _nicknameController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome, ${_nicknameController.text}!')),
        );

        // Navigate to the main screen
        Navigator.pushReplacementNamed(context, '/main');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : null,
                child: _selectedImage == null
                    ? Icon(Icons.add_a_photo,
                    size: 50, color: Colors.teal.shade400)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Upload a profile picture",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: 'Nickname',
                prefixIcon: const Icon(Icons.person, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _birthDateController,
              readOnly: true, // Make the TextField non-editable
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.teal, // Header background color
                          onPrimary: Colors.white, // Header text color
                          onSurface: Colors.black, // Body text color
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.teal, // Button text color
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedDate != null) {
                  String formattedDate =
                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  _birthDateController.text = formattedDate;
                }
              },
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                prefixIcon:
                const Icon(Icons.calendar_today, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.1).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: ElevatedButton(
                onPressed: _onSignUpPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 32.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
