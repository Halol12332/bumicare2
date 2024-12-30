import 'package:bumicare2/accounts_handling/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();

  Future<void> _handleLogin(BuildContext context) async {
    // Call your login method (e.g., loginWithGoogle)
    final user = await authService.loginWithGoogle(context);

    if (user != null) {
      // Save username (email) in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('username', user.email!);  // Save the email (or username)

      // Check if user exists in Firestore
      final email = user.email;
      final docRef = FirebaseFirestore.instance.collection('users').doc(email);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        // User exists, navigate to main screen
        Navigator.pushReplacementNamed(context, '/main'); // Replace with your main screen route name
      } else {
        // User doesn't exist, navigate to sign-up screen and pass user data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InteractiveSignUpScreen(
              userData: {
                'email': user.email,
                'fullName': user.displayName ?? 'New User',
              },
            ),
          ),
        );
      }
    } else {
      // Handle login failure (e.g., show an error message)
      print('Login failed.');
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
                onPressed: () => _handleLogin(context),
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