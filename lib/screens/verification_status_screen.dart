import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../widgets/app_drawer.dart';
import '../widgets/reupload_button.dart';

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() =>
      _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen>
    with TickerProviderStateMixin {
  final picker = ImagePicker();

  late AnimationController headerController;
  late AnimationController cardController;

  bool isUploading = false;

  @override
  void initState() {
    super.initState();

    headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    headerController.dispose();
    cardController.dispose();
    super.dispose();
  }

  // SAFEST camera/gallery selection
  Future<ImageSource> _getSafeImageSource() async {
    if (kIsWeb) return ImageSource.gallery;

    try {
      final deviceInfo = DeviceInfoPlugin();
      final android = await deviceInfo.androidInfo;

      final bool isEmulator = !android.isPhysicalDevice;
      return isEmulator ? ImageSource.gallery : ImageSource.camera;
    } catch (e) {
      return ImageSource.gallery;
    }
  }

  Future<void> handleReUpload({required bool isLicence}) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final source = await _getSafeImageSource();
    final XFile? photo = await picker.pickImage(source: source);
    if (photo == null) return;

    setState(() => isUploading = true);

    File file = File(photo.path);
    final base64 = base64Encode(await file.readAsBytes());

    final field = isLicence ? "licenceBase64" : "insuranceBase64";

    await FirebaseFirestore.instance.collection("users").doc(uid).set({
      "verified": false,
      "verificationSubmitted": true,
      field: base64,
      if (isLicence) "licencePath": null else "insurancePath": null,
    }, SetOptions(merge: true));

    setState(() => isUploading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.lightGreen,
          content: Text(
            isLicence
                ? "Licence re-uploaded successfully!"
                : "Insurance re-uploaded successfully!",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Stack(
      children: [
        Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(
            title: const Text("Verification Status"),
            backgroundColor: Colors.lightGreen,
          ),
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.lightGreen),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>?;

              if (data == null) {
                return const Center(child: Text("No verification data found."));
              }

              final licencePath = data["licencePath"];
              final insurancePath = data["insurancePath"];
              final licenceBase64 = data["licenceBase64"];
              final insuranceBase64 = data["insuranceBase64"];
              final verified = data["verified"] == true;
              final submitted = data["verificationSubmitted"] == true;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: headerController,
                        curve: Curves.easeOutBack,
                      ),
                      child: FadeTransition(
                        opacity: headerController,
                        child: _buildHeader(verified, submitted),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: cardController,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: FadeTransition(
                        opacity: cardController,
                        child: _buildDocumentCard(
                          title: "Professional Licence",
                          path: licencePath,
                          base64: licenceBase64,
                          onReupload: () => handleReUpload(isLicence: true),
                          icon: Icons.badge,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: cardController,
                              curve: Interval(0.2, 1, curve: Curves.easeOut),
                            ),
                          ),
                      child: FadeTransition(
                        opacity: cardController,
                        child: _buildDocumentCard(
                          title: "Insurance Certificate",
                          path: insurancePath,
                          base64: insuranceBase64,
                          onReupload: () => handleReUpload(isLicence: false),
                          icon: Icons.shield,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        if (isUploading)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: const Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  color: Colors.lightGreen,
                  strokeWidth: 7,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(bool verified, bool submitted) {
    String text;
    Color color;

    if (verified) {
      text = "VERIFIED ✓";
      color = Colors.green;
    } else if (submitted) {
      text = "PENDING REVIEW";
      color = Colors.orange;
    } else {
      text = "NOT SUBMITTED ✗";
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.lightGreen.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.lightGreen.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_user, size: 60, color: Colors.lightGreen),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            verified
                ? "Your account is fully verified!"
                : submitted
                ? "Your documents are under review."
                : "Upload your documents to get verified.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String? path,
    required String? base64,
    required VoidCallback onReupload,
    required IconData icon,
  }) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: 1.0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.lightGreen.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.lightGreen, size: 30),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImagePreview(
                path,
                base64,
                fallback: "No document uploaded.",
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: ReUploadButton(label: "Re-upload", onPressed: onReupload),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(
    String? path,
    String? base64, {
    required String fallback,
  }) {
    // 1️⃣ Base64 ALWAYS wins
    if (base64 != null) {
      return Image.memory(
        base64Decode(base64),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    // 2️⃣ Local file fallback
    if (!kIsWeb && path != null && File(path).existsSync()) {
      return Image.file(
        File(path),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return _fallbackBox(fallback);
  }

  Widget _fallbackBox(String text) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: Colors.grey.shade600)),
    );
  }
}
