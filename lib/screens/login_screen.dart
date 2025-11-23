// LOGIN SCREEN — CLEANED AND CORRECT
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/input_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_message_box.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  String? messageText;
  Color messageColor = Colors.red;
  bool loading = false;

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      final data = doc.data();
      final role = data?["role"];
      final verified = data?["verified"] == true;

      // Message
      setState(() {
        messageText = "Login Successful!";
        messageColor = Colors.green;
      });

      await Future.delayed(const Duration(milliseconds: 350));

      // NEW USER → Choose role
      if (role == null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/choose_role",
          (_) => false,
        );
        return;
      }

      // ADMIN
      if (data?["isAdmin"] == true || role == "admin") {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/admin_panel",
          (_) => false,
        );
        return;
      }

      // RESIDENT
      if (role == "resident") {
        Navigator.pushNamedAndRemoveUntil(context, "/dashboard", (_) => false);
        return;
      }

      // PROFESSIONAL
      if (role == "professional") {
        if (!verified) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/verification_status",
            (_) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/available_jobs",
            (_) => false,
          );
        }
        return;
      }

      // fallback
      Navigator.pushNamedAndRemoveUntil(context, "/choose_role", (_) => false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        messageText = e.message ?? "Login failed.";
        messageColor = Colors.red;
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Icon(Icons.build, size: 80, color: Colors.blue),
                const SizedBox(height: 24),
                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                InputField(
                  label: "Email",
                  controller: emailController,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter your email" : null,
                ),

                const SizedBox(height: 16),

                InputField(
                  label: "Password",
                  controller: passController,
                  obscure: true,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter password" : null,
                ),

                const SizedBox(height: 20),

                if (messageText != null)
                  StatusMessageBox(text: messageText!, color: messageColor),

                const SizedBox(height: 12),

                PrimaryButton(
                  label: "Sign In",
                  loading: loading,
                  onPressed: handleLogin,
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/signup"),
                  child: const Text(
                    "No account? Sign Up",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
