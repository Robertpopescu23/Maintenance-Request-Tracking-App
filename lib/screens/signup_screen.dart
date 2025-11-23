import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/primary_button.dart';
import '../widgets/input_field.dart';
import '../widgets/status_message_box.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  String? messageText;
  Color messageColor = Colors.red;
  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> handleSignUp() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passController.text.trim(),
          );

      final uid = credential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      setState(() {
        messageText = "Account created successfully!";
        messageColor = Colors.green;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        messageText = e.message ?? "Signup error.";
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
                const SizedBox(height: 20),
                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                InputField(
                  label: "Name",
                  controller: nameController,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter your name" : null,
                ),
                const SizedBox(height: 16),

                InputField(
                  label: "Email",
                  controller: emailController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Enter your email";
                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                    if (!emailRegex.hasMatch(v)) return "Invalid email";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                InputField(
                  label: "Password",
                  controller: passController,
                  obscure: true,
                  validator: (v) =>
                      v == null || v.length < 6 ? "Min 6 characters" : null,
                ),
                const SizedBox(height: 20),

                if (messageText != null)
                  StatusMessageBox(text: messageText!, color: messageColor),
                const SizedBox(height: 12),

                PrimaryButton(
                  label: "Sign Up",
                  onPressed: handleSignUp,
                  loading: loading,
                ),

                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/login"),
                  child: const Text(
                    "Already have an account? Sign in",
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
