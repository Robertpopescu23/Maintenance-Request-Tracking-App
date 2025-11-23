// AUTH GATE — CLEAN AND SAFE
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Map<String, dynamic>?> loadUser(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _LoadingSplash();
        }

        // Not logged in → Welcome screen
        if (!snap.hasData) {
          Future.microtask(() {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/welcome",
              (_) => false,
            );
          });
          return const _LoadingSplash();
        }

        final user = snap.data!;

        return FutureBuilder<Map<String, dynamic>?>(
          future: loadUser(user.uid),
          builder: (context, docSnap) {
            if (!docSnap.hasData) return const _LoadingSplash();

            final data = docSnap.data;
            final role = data?["role"];
            final verified = data?["verified"] == true;

            // New user → choose role
            if (role == null) {
              Future.microtask(() {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/choose_role",
                  (_) => false,
                );
              });
              return const _LoadingSplash();
            }

            // Admin
            if (role == "admin" || data?["isAdmin"] == true) {
              Future.microtask(() {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/admin_panel",
                  (_) => false,
                );
              });
              return const _LoadingSplash();
            }

            // Resident
            if (role == "resident") {
              Future.microtask(() {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/dashboard",
                  (_) => false,
                );
              });
              return const _LoadingSplash();
            }

            // Professional
            if (role == "professional") {
              Future.microtask(() {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  verified ? "/available_jobs" : "/verification_status",
                  (_) => false,
                );
              });
              return const _LoadingSplash();
            }

            // fallback
            Future.microtask(() {
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/welcome",
                (_) => false,
              );
            });

            return const _LoadingSplash();
          },
        );
      },
    );
  }
}

class _LoadingSplash extends StatelessWidget {
  const _LoadingSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator(color: Colors.blue)),
    );
  }
}
