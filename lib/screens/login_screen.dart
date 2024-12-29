//this is login_screen.dart
import 'dart:convert';
import 'package:bumicare2/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      // Attempt Google Sign-In
      final user = await authService.signInWithGoogle();
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In was canceled')),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      // Retrieve stored accounts
      final accountsJson = prefs.getString('accounts') ?? '[]';
      final List<dynamic> accounts = jsonDecode(accountsJson);

      // Check if the user already exists in the accounts
      final existingAccount = accounts.firstWhere(
            (account) => account['email'] == user.email, // Cek berdasarkan email
        orElse: () => null,
      );

      if (existingAccount != null) {
        // Existing user, redirect to the main screen
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', existingAccount['nickname']);
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        // New user, redirect to sign-up screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InteractiveSignUpScreen(
              userData: {
                'email': user.email,
                'fullName': user.displayName,
                'profilePicture': user.photoURL,
              },
            ),
          ),
        );
      }
    } catch (e) {
      print("Login Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during sign-in')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main logo placeholder replaced with an image
              Image.asset(
                '../assets/logo/main_logo.png',
                height: 180.0,
                width: 180.0,
                fit: BoxFit.contain, // Ensures the logo fits within the dimensions
              ),
              const SizedBox(height: 32.0),
              const Text(
                'Welcome to BumiCare App',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'A better way to care for the planet.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32.0),
              // Google Sign-In button
              ElevatedButton(
                onPressed: () => loginWithGoogle(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        '../assets/logo/google.jpeg',
                        height: 34.0,
                        width: 34.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              // Footer text
              const Text(
                'By continuing, you agree to our Terms & Privacy Policy.',
                style: TextStyle(fontSize: 12.0, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
