import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart'; // import SignUpScreen
import 'screens/choose_role.dart'; // import ChooseRoleScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quick Fix',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WelcomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) =>
            const SignUpScreen(), // updated to actual SignUpScreen
        '/choose_role': (context) => const ChooseRoleScreen(),
      },
    );
  }
}
