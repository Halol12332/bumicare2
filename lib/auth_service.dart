//this is auth_service.dart
import 'dart:convert';

import 'package:bumicare2/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled the sign-in

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Error during Google Sign-In: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

Future<void> loginWithGoogle(BuildContext context) async {
  try {
    // Attempt Google Sign-In
    final AuthService authService = AuthService();
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


Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('isLoggedIn');
  await prefs.remove('username');

  Navigator.pushNamedAndRemoveUntil(
    context,
    '/',
        (route) => false,
  );
}