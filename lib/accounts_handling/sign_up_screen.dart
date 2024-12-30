import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;

  final List<String> _avatars = [
    '../assets/avatar_leaderboards/avatar1.png',
    '../assets/avatar_leaderboards/avatar2.png',
    '../assets/avatar_leaderboards/avatar3.png',
    '../assets/avatar_leaderboards/avatar4.png',
    '../assets/avatar_leaderboards/avatar5.png',
    '../assets/avatar_leaderboards/avatar6.png',
    '../assets/avatar_leaderboards/avatar7.png',
  ];
  int _currentAvatarIndex = 0;

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

  bool _isValidPhoneNumber(String input) {
    final RegExp regex = RegExp(r'^\+?[\d\s]{10,15}$'); // Example regex for international phone numbers
    return regex.hasMatch(input);
  }

  void _onSignUpPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    try {
      final userRef =
      FirebaseFirestore.instance.collection('users').doc(widget.userData['email']);

      final userData = {
        'nickname': _nicknameController.text.trim(),
        'phoneNumber': _phoneNumberController.text.trim(),
        'birthDate': _birthDateController.text.trim(),
        'email': widget.userData['email'],
        'avatar': _avatars[_currentAvatarIndex],
        'level': 1,
        'CO2saved': 0,
        'exp': 0,
        'achievements': [],
      };

      await userRef.set(userData);
      await prefs.setString('username', widget.userData['email']);
      await prefs.setBool('isLoggedIn', true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, ${_nicknameController.text}!')),
      );

      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      print("Error saving user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving user data')),
      );
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left, size: 40, color: Colors.teal),
                    onPressed: () {
                      setState(() {
                        _currentAvatarIndex =
                            (_currentAvatarIndex - 1 + _avatars.length) % _avatars.length;
                      });
                    },
                  ),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(_avatars[_currentAvatarIndex]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right, size: 40, color: Colors.teal),
                    onPressed: () {
                      setState(() {
                        _currentAvatarIndex =
                            (_currentAvatarIndex + 1) % _avatars.length;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Choose your avatar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nicknameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nickname is required';
                  }
                  if (value.length < 3 || value.length > 20) {
                    return 'Nickname must be between 3 and 20 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Nickname',
                  prefixIcon: const Icon(Icons.person, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (!_isValidPhoneNumber(value.trim())) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Date of Birth is required';
                  }
                  return null;
                },
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
                  prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
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
      ),
    );
  }
}
