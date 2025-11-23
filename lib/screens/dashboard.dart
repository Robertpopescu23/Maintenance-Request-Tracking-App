import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../widgets/app_drawer.dart';
import '../widgets/input_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/ticket_card.dart';

import '../services/ticket_service.dart';
import '../models/ticket_model.dart';

import '../utils/job_categories.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final formKey = GlobalKey<FormState>();
  final ticketController = TextEditingController();

  bool showInput = false;
  bool submitting = false;

  // Default category (lowercase normalized)
  String selectedCategory = jobCategories.first.toLowerCase();
  String filterCategory = "all"; // lowercase

  @override
  void dispose() {
    ticketController.dispose();
    super.dispose();
  }

  void toggleInput() {
    setState(() => showInput = !showInput);
  }

  /// Convert category to Title Case for UI
  String toTitleCase(String text) {
    return text
        .split(" ")
        .map((w) {
          if (w.isEmpty) return "";
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        })
        .join(" ");
  }

  Future<void> submitTicket() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => submitting = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final formattedTime = DateFormat(
      "dd MMM yyyy, HH:mm",
    ).format(DateTime.now());

    final ticket = Ticket(
      id: "",
      text: ticketController.text.trim(),
      timestamp: formattedTime,
      userId: uid,
      status: "pending",
      category: selectedCategory.trim().toLowerCase(), // NORMALIZED CATEGORY
    );

    await TicketService.addTicket(ticket);

    setState(() {
      submitting = false;
      showInput = false;
      ticketController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                "Dashboard",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // CATEGORY FILTER
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: filterCategory,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(
                      value: "all",
                      child: Text("All Categories"),
                    ),
                    ...jobCategories.map(
                      (cat) => DropdownMenuItem(
                        value: cat.toLowerCase(),
                        child: Text(toTitleCase(cat)),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() => filterCategory = val!);
                  },
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: StreamBuilder<List<Ticket>>(
                  stream: TicketService.getTicketsByCategory(
                    uid,
                    filterCategory == "all"
                        ? null
                        : filterCategory.trim().toLowerCase(),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      );
                    }

                    final tickets = snapshot.data!;

                    return ListView(
                      children: [
                        // MAIN CARD
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // HEADER
                              Container(
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        "My Tickets",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      onPressed: toggleInput,
                                    ),
                                  ],
                                ),
                              ),

                              if (showInput)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Form(
                                    key: formKey,
                                    child: Column(
                                      children: [
                                        InputField(
                                          label: "Describe your issue",
                                          controller: ticketController,
                                          validator: (v) =>
                                              v == null || v.isEmpty
                                              ? "Required"
                                              : null,
                                        ),

                                        const SizedBox(height: 16),

                                        // CATEGORY DROPDOWN (normalized)
                                        DropdownButtonFormField<String>(
                                          value: selectedCategory,
                                          decoration: InputDecoration(
                                            labelText: "Category",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          items: jobCategories
                                              .map(
                                                (cat) => DropdownMenuItem(
                                                  value: cat.toLowerCase(),
                                                  child: Text(toTitleCase(cat)),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) {
                                            setState(
                                              () => selectedCategory = v!,
                                            );
                                          },
                                        ),

                                        const SizedBox(height: 16),

                                        PrimaryButton(
                                          label: "Submit Ticket",
                                          loading: submitting,
                                          onPressed: submitTicket,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // DISPLAY TICKETS
                              ...tickets.map(
                                (t) => TicketCard(
                                  title:
                                      "${t.text} (${toTitleCase(t.category)})",
                                  timestamp: t.timestamp,
                                  status: t.status,
                                  onTap: null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
