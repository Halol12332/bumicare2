//this is main.dart
import 'package:bumicare2/firebase_options.dart';
import 'package:bumicare2/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: "535728154791-7ffioh2jrfvu07k0jc2s3cqj56dnkkmh.apps.googleusercontent.com",
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => const AdditionalInfoScreen(),
        '/main': (context) => MainScreen(),
        '/profile': (context) => UserProfileScreen(),
        '/rewards': (context) => RewardsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
