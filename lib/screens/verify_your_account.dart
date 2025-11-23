import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';

class VerifyYourAccountScreen extends StatefulWidget {
  const VerifyYourAccountScreen({Key? key}) : super(key: key);

  @override
  State<VerifyYourAccountScreen> createState() =>
      _VerifyYourAccountScreenState();
}

class _VerifyYourAccountScreenState extends State<VerifyYourAccountScreen> {
  Future<String> convertToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<String> saveLocally(File file, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = "${dir.path}/verification/$filename";

    final saveDir = Directory("${dir.path}/verification");
    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }

    final savedFile = await file.copy(savePath);
    return savedFile.path;
  }

  // EMULATOR DETECTION
  Future<bool> isAndroidEmulator() async {
    final deviceInfo = DeviceInfoPlugin();
    final android = await deviceInfo.androidInfo;
    return !android.isPhysicalDevice; // true = emulator
  }

  //  IMAGE PICKER
  File? licenceImage;
  File? insuranceImage;

  bool licenceSubmitted = false;
  bool insuranceSubmitted = false;

  final ImagePicker picker = ImagePicker();

  Future<void> pickLicence() async {
    final bool emulator = await isAndroidEmulator();

    final XFile? photo = await picker.pickImage(
      source: emulator ? ImageSource.gallery : ImageSource.camera,
    );

    if (photo != null) {
      setState(() {
        licenceImage = File(photo.path);
        licenceSubmitted = true;
      });
    }
  }

  Future<void> pickInsurance() async {
    final bool emulator = await isAndroidEmulator();

    final XFile? photo = await picker.pickImage(
      source: emulator ? ImageSource.gallery : ImageSource.camera,
    );

    if (photo != null) {
      setState(() {
        insuranceImage = File(photo.path);
        insuranceSubmitted = true;
      });
    }
  }

  //  UI BEGIN
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text("Verify Your Account"),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Colors.lightGreen,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Verify Your Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Shield Icon
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.shield,
                            size: 110,
                            color: Colors.transparent,
                          ),
                          const Icon(
                            Icons.shield_outlined,
                            size: 115,
                            color: Colors.black,
                          ),
                          ClipPath(
                            clipper: _LeftHalfClipper(),
                            child: const Icon(
                              Icons.shield,
                              size: 100,
                              color: Colors.lightGreen,
                            ),
                          ),
                          ClipPath(
                            clipper: _RightHalfClipper(),
                            child: const Icon(
                              Icons.shield,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Upload required documents.",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 25),

                      GestureDetector(
                        onTap: pickLicence,
                        child: _buildDocumentBox(
                          title: "Professional Licence",
                          imageFile: licenceImage,
                          submitted: licenceSubmitted,
                        ),
                      ),

                      const SizedBox(height: 25),

                      GestureDetector(
                        onTap: pickInsurance,
                        child: _buildDocumentBox(
                          title: "Insurance Certificate",
                          imageFile: insuranceImage,
                          submitted: insuranceSubmitted,
                        ),
                      ),

                      const SizedBox(height: 30),

                      //  SUBMIT BUTTON
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              final uid =
                                  FirebaseAuth.instance.currentUser!.uid;

                              String? licencePath;
                              String? insurancePath;
                              String? licenceBase64;
                              String? insuranceBase64;

                              // Licence
                              if (licenceImage != null) {
                                // 1. Save locally on Android/iOS
                                if (!kIsWeb) {
                                  licencePath = await saveLocally(
                                    licenceImage!,
                                    "licence.jpg",
                                  );
                                }

                                // 2. Convert to Base64 (for admin/web)
                                licenceBase64 = await convertToBase64(
                                  licenceImage!,
                                );
                              }

                              // Insurance
                              if (insuranceImage != null) {
                                if (!kIsWeb) {
                                  insurancePath = await saveLocally(
                                    insuranceImage!,
                                    "insurance.jpg",
                                  );
                                }

                                insuranceBase64 = await convertToBase64(
                                  insuranceImage!,
                                );
                              }

                              // Save everything in Firestore
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(uid)
                                  .set({
                                    "verified": false,
                                    "verificationSubmitted": true,

                                    // Local-only paths (mobile)
                                    "licencePath": licencePath,
                                    "insurancePath": insurancePath,

                                    // Base64 (mobile + web)
                                    "licenceBase64": licenceBase64,
                                    "insuranceBase64": insuranceBase64,
                                  }, SetOptions(merge: true));

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Documents submitted!"),
                                ),
                              );

                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Submit for Review",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- DOCUMENT BOX ----------
  Widget _buildDocumentBox({
    required String title,
    required File? imageFile,
    required bool submitted,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.25),
          width: 2,
        ),
      ),
      child: submitted
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    imageFile!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.yellow.shade300),
                    ),
                    child: const Text(
                      "Pending",
                      style: TextStyle(
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade100.withValues(alpha: 0.8),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Checking validity of the document...",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    title == "Professional Licence"
                        ? Icons.badge
                        : Icons.shield,
                    size: 50,
                    color: Colors.grey.withValues(alpha: 0.25),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}

//  CLIPPERS
class _LeftHalfClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) =>
      Path()..addRect(Rect.fromLTRB(0, 0, size.width / 2, size.height));

  @override
  bool shouldReclip(oldClipper) => false;
}

class _RightHalfClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) =>
      Path()
        ..addRect(Rect.fromLTRB(size.width / 2, 0, size.width, size.height));

  @override
  bool shouldReclip(oldClipper) => false;
}
