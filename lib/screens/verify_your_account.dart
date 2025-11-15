import 'package:flutter/material.dart';

class VerifyYourAccountScreen extends StatelessWidget {
  const VerifyYourAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text("Verify Your Account"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(22.0),

        child: Column(
          children: [
            // Main Verification Box
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
                  // FIX OVERFLOW
                  child: Column(
                    children: [
                      // Header (top 1/4)
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
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // SHIELD ICON WITH BLACK BORDER
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.shield,
                            size: 110,
                            color: Colors.transparent,
                          ),

                          Icon(
                            Icons.shield_outlined,
                            size: 115,
                            color: Colors.black,
                          ),

                          ClipPath(
                            clipper: _LeftHalfClipper(),
                            child: Icon(
                              Icons.shield,
                              size: 100,
                              color: Colors.lightGreen,
                            ),
                          ),

                          ClipPath(
                            clipper: _RightHalfClipper(),
                            child: Icon(
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

                      const SizedBox(height: 20),

                      // 🔹 DOCUMENT BOX 1 — Professional Licence
                      Container(
                        width: double.infinity,
                        height: 120,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.25),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.badge,
                              size: 50,
                              color: Colors.grey.withValues(alpha: 0.25),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Professional Licence",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔹 DOCUMENT BOX 2 — Insurance Certificate
                      Container(
                        width: double.infinity,
                        height: 120,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.25),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield,
                              size: 50,
                              color: Colors.grey.withValues(alpha: 0.25),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Insurance Certificate",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // SUBMIT BUTTON
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {},
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
}

// Clip left half of shield
class _LeftHalfClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()..addRect(Rect.fromLTRB(0, 0, size.width / 2, size.height));
  }

  @override
  bool shouldReclip(oldClipper) => false;
}

// Clip right half of shield
class _RightHalfClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTRB(size.width / 2, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(oldClipper) => false;
}
