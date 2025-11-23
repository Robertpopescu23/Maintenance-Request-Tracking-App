import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ticket_model.dart';
import '../services/ticket_service.dart';
import '../widgets/app_drawer.dart';

class AcceptedJobsScreen extends StatelessWidget {
  const AcceptedJobsScreen({super.key});

  Stream<List<Ticket>> getInProgressJobs() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection("tickets")
        .where("professionalId", isEqualTo: uid)
        .where("status", isEqualTo: "in_progress")
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Ticket.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Accepted Jobs"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<Ticket>>(
        stream: getInProgressJobs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          final jobs = snapshot.data!;
          if (jobs.isEmpty) {
            return const Center(child: Text("No accepted jobs yet."));
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
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
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

                    Text("Category: ${job.category}"),
                    Text("Submitted: ${job.timestamp}"),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: () async {
                        await TicketService.completeJob(job.id);

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Job marked as Done")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Done"),
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
