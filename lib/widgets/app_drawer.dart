// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/verification_status_screen.dart';
// import '../screens/accepted_jobs_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<String?> _loadRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data()?['role'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<String?>(
        future: _loadRole(),
        builder: (context, snapshot) {
          final role = snapshot.data;

          return Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.person, color: Colors.white, size: 50),
                    SizedBox(height: 10),
                    Text(
                      "Quick Fix",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // DASHBOARD
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Dashboard"),
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/dashboard',
                    (route) => false,
                  );
                },
              ),

              // PROFESSIONAL EXTRAS
              if (role == 'professional') ...[
                ListTile(
                  leading: const Icon(Icons.verified_user, color: Colors.green),
                  title: const Text("Verification Status"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VerificationStatusScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.work_history, color: Colors.orange),
                  title: const Text("Accepted Jobs"),
                  onTap: () {
                    Navigator.pushNamed(context, '/accepted_jobs');
                  },
                ),
              ],

              // 🔹 MAP ENTRY FOR BOTH ROLES
              if (role == 'resident' || role == 'professional') ...[
                ListTile(
                  leading: const Icon(Icons.map, color: Colors.blue),
                  title: Text(
                    role == 'resident'
                        ? "See Available Professionals"
                        : "See Available Residents",
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/nearby_users');
                  },
                ),
              ],

              const Spacer(),

              // LOGOUT
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
