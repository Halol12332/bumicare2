//this is sign_up_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "535728154791-7ffioh2jrfvu07k0jc2s3cqj56dnkkmh.apps.googleusercontent.com", // Replace with your Google client ID
  );

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

  Future<void> _signUp(BuildContext context) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar(context, 'All fields are required');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar(context, 'Passwords do not match');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString('accounts') ?? '[]';
    final List<dynamic> accounts = jsonDecode(accountsJson);

    if (accounts.any((account) => account['username'] == username)) {
      _showSnackBar(context, 'Username already exists');
      return;
    }

    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    accounts.add({
      'username': username,
      'password': hashedPassword,
    });

    await prefs.setString('accounts', jsonEncode(accounts));
    _showSnackBar(context, 'Account created successfully');

    await _askForNickname(context, username);
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', user.email ?? '');

        await _askForNickname(context, user.email ?? '');
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      _showSnackBar(context, 'Google Sign-In failed: $e');
    }
  }

  Future<void> _askForNickname(BuildContext context, String username) async {
    final nicknameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('What should we call you?'),
          content: TextField(
            controller: nicknameController,
            decoration: InputDecoration(hintText: 'Enter your nickname'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final nickname = nicknameController.text.trim();
                if (nickname.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  final accountsJson = prefs.getString('accounts') ?? '[]';
                  final List<dynamic> accounts = jsonDecode(accountsJson);

                  final userIndex =
                  accounts.indexWhere((account) => account['username'] == username);
                  if (userIndex != -1) {
                    accounts[userIndex]['nickname'] = nickname;
                    await prefs.setString('accounts', jsonEncode(accounts));
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                child: _selectedImage == null ? Icon(Icons.camera_alt, size: 50) : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signUp(context),
              child: Text('Sign Up'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _signInWithGoogle(context),
              icon: Icon(Icons.account_circle),
              label: Text('Sign Up with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
