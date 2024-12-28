import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  Future<void> loginWithGoogle(BuildContext context) async {
    final user = await authService.signInWithGoogle();

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();

      // Check if user has logged in before
      final accountsJson = prefs.getString('accounts') ?? '[]';
      final List<dynamic> accounts = accountsJson.isNotEmpty
          ? jsonDecode(accountsJson)
          : <dynamic>[];
      final existingAccount = accounts.firstWhere(
              (account) => account['email'] == user.email,
          orElse: () => null);

      if (existingAccount == null) {
        // New user, redirect to additional info screen
        Navigator.pushNamed(context, '/signup', arguments: {
          'email': user.email,
          'fullName': user.displayName,
          'profilePicture': user.photoURL,
        });
      } else {
        // Existing user, proceed to home screen
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', existingAccount['nickname'] ?? '');

        Navigator.pushReplacementNamed(context, '/');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-In failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('login_screen.dart'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo utama
            Image.asset(
              '../assets/logo/main_logo.png',
              height: 300.0, // Ukuran logo utama
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16.0),
            // Teks selamat datang
            const Text(
              'Welcome to BumiCare App',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 32.0),
            // Tombol Google Sign-In
            ElevatedButton(
              onPressed: () => loginWithGoogle(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
                      height: 34.0, // Ukuran logo Google
                      width: 34.0,  // Tambahkan lebar agar gambar tetap proporsional
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
          ],
        ),
      ),
    );
  }
}
