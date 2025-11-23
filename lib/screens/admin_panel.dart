import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String searchQuery = "";
  bool showOnlyUnverified = true;

  CollectionReference<Map<String, dynamic>> get usersRef =>
      FirebaseFirestore.instance.collection("users");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Admin Verification Panel"),
        backgroundColor: Colors.lightGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Optional: handle logout in admin if you want
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/welcome",
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // 🔍 SEARCH + FILTER BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                // Search
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search by name or email...",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => searchQuery = value.trim().toLowerCase());
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Toggle: Only unverified / all
                FilterChip(
                  label: const Text("Only unverified"),
                  selected: showOnlyUnverified,
                  onSelected: (val) {
                    setState(() => showOnlyUnverified = val);
                  },
                  selectedColor: Colors.lightGreen.shade100,
                  checkmarkColor: Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: usersRef
                  .where("role", isEqualTo: "professional")
                  .where("verificationSubmitted", isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading data:\n${snapshot.error}",
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.lightGreen),
                  );
                }

                // All professionals with verificationSubmitted == true
                final docs = snapshot.data!.docs;

                // Filter in memory for search + verified flag
                final filtered = docs.where((doc) {
                  final data = doc.data();

                  final name = (data["name"] as String?)?.toLowerCase() ?? "";
                  final email = (data["email"] as String?)?.toLowerCase() ?? "";
                  final verified = data["verified"] == true;

                  // filter: only unverified if toggle is ON
                  if (showOnlyUnverified && verified) return false;

                  // Search filter
                  if (searchQuery.isEmpty) return true;
                  return name.contains(searchQuery) ||
                      email.contains(searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      "No professionals found for current filters.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final userDoc = filtered[index];
                    final data = userDoc.data();

                    final userId = userDoc.id;
                    final name = data["name"] as String?;
                    final email = data["email"] as String?;
                    final verified = data["verified"] == true;
                    final licence = data["licenceBase64"] as String?;
                    final insurance = data["insuranceBase64"] as String?;

                    return _buildUserCard(
                      userId: userId,
                      name: name,
                      email: email,
                      verified: verified,
                      licenceBase64: licence,
                      insuranceBase64: insurance,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // USER CARD

  Widget _buildUserCard({
    required String userId,
    String? name,
    String? email,
    required bool verified,
    String? licenceBase64,
    String? insuranceBase64,
  }) {
    final displayName = name?.isNotEmpty == true ? name! : "Unknown user";
    final displayEmail = email?.isNotEmpty == true
        ? email!
        : "No email available";

    final statusColor = verified ? Colors.green : Colors.orange;
    final statusText = verified ? "Verified" : "Pending review";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: avatar + name + email + status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.lightGreen.shade100,
                  child: const Icon(Icons.person, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              verified
                                  ? Icons.verified
                                  : Icons.hourglass_top_rounded,
                              size: 16,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // LICENCE IMAGE
            const Text(
              "Professional Licence",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _buildImageBox(licenceBase64),

            const SizedBox(height: 12),

            // INSURANCE IMAGE
            const Text(
              "Insurance Certificate",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _buildImageBox(insuranceBase64),

            const SizedBox(height: 16),

            // BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveUser(userId),
                    icon: const Icon(Icons.check),
                    label: const Text("Approve"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _declineUser(userId),
                    icon: const Icon(Icons.close),
                    label: const Text("Decline"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //  IMAGE BOX (Base64)

  Widget _buildImageBox(String? base64) {
    if (base64 != null && base64.isNotEmpty) {
      try {
        final bytes = base64Decode(base64);
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            bytes,
            height: 170,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {
        // If base64 is invalid, show error box instead of crashing
        return _placeholderBox(
          text: "Invalid image data. Ask user to re-upload.",
          icon: Icons.broken_image,
        );
      }
    }

    return _placeholderBox(
      text: "No document uploaded",
      icon: Icons.image_not_supported,
    );
  }

  Widget _placeholderBox({required String text, required IconData icon}) {
    return Container(
      height: 170,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: Colors.grey.shade600),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ========== APPROVE / DECLINE ==========

  Future<void> _approveUser(String userId) async {
    final confirmed = await _showConfirmDialog(
      title: "Approve verification?",
      message: "This professional will be marked as verified.",
      confirmText: "Approve",
      confirmColor: Colors.green,
    );
    if (!confirmed) return;

    await usersRef.doc(userId).update({
      "verified": true,
      "verificationSubmitted": false,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("User approved and marked as verified."),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _declineUser(String userId) async {
    final confirmed = await _showConfirmDialog(
      title: "Decline verification?",
      message:
          "Their documents will be cleared. They will need to re-upload new files.",
      confirmText: "Decline",
      confirmColor: Colors.red,
    );
    if (!confirmed) return;

    await usersRef.doc(userId).update({
      "verified": false,
      "verificationSubmitted": false,
      "licenceBase64": null,
      "insuranceBase64": null,
      "licencePath": null,
      "insurancePath": null,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("User declined and documents cleared."),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ========== CONFIRM DIALOG ==========

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
