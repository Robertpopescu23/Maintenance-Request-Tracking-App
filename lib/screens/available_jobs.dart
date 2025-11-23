import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/app_drawer.dart';
import '../services/ticket_service.dart';
import '../models/ticket_model.dart';
import 'verify_your_account.dart';

class AvailableJobsScreen extends StatelessWidget {
  const AvailableJobsScreen({super.key});

  Future<bool> checkVerification() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    // If no field exists → treat as not verified
    return snapshot.data()?["verified"] == true;
  }

  @override
  Widget build(BuildContext context) {
    final professionalId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          "Available Jobs",
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: StreamBuilder<List<Ticket>>(
        stream: TicketService.getPendingJobs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          final jobs = snapshot.data!;

          if (jobs.isEmpty) {
            return const Center(child: Text("No available jobs right now."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Category: ${job.category}",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),

                    Text(
                      "Submitted: ${job.timestamp}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ACCEPT JOB BUTTON WITH VERIFICATION CHECK
                    ElevatedButton(
                      onPressed: () async {
                        final isVerified = await checkVerification();

                        if (!isVerified) {
                          // Redirect unverified professionals
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VerifyYourAccountScreen(),
                            ),
                          );
                          return;
                        }

                        try {
                          //Accept jobs normally
                          await TicketService.acceptJob(job.id, professionalId);

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Job accepted!")),
                          );
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed to accept job: $e")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Accept Job"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
