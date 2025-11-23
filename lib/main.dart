import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/choose_role.dart';
import 'screens/dashboard.dart';
import 'screens/available_jobs.dart';
import 'screens/auth_gate.dart';
import 'screens/verification_status_screen.dart';
import 'screens/admin_panel.dart';
import 'screens/accepted_jobs_screen.dart';
import 'screens/nearby_users_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

      initialRoute: '/welcome',

      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/choose_role': (context) => const ChooseRoleScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/available_jobs': (context) => const AvailableJobsScreen(),
        '/verification_status': (context) => const VerificationStatusScreen(),
        '/accepted_jobs': (context) => AcceptedJobsScreen(),
        '/nearby_users': (context) => const NearbyUsersScreen(),
        '/admin_panel': (context) => const AdminPanel(),
        '/auth_gate': (context) => const AuthGate(),
      },
    );
  }
}
