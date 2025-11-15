import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ticket_description.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool showInput = false;
  final TextEditingController ticketController = TextEditingController();

  final List<Map<String, String>> tickets = [];

  void handleAddTicket() {
    setState(() {
      showInput = !showInput;
    });
  }

  void handleSubmitTicket() {
    final text = ticketController.text.trim();
    if (text.isNotEmpty) {
      final timestamp = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());

      setState(() {
        tickets.add({'text': text, 'timestamp': timestamp});
        ticketController.clear();
        showInput = false;
      });
    }
  }

  void goToTicketDescription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketDescriptionScreen(tickets: tickets),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                'Dashboard',
                style: TextStyle(fontSize: 26, color: Colors.black),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // MAIN TICKET BOX
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
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
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'My Tickets',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: handleAddTicket,
                              icon: const Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                      // INPUT FIELD
                      if (showInput)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextField(
                                controller: ticketController,
                                decoration: InputDecoration(
                                  hintText: "Enter your ticket",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: handleSubmitTicket,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Submit"),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // TICKET LIST DISPLAY
                      Expanded(
                        child: tickets.isEmpty
                            ? Center(
                                child: Text(
                                  'No tickets yet',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: tickets.length,
                                itemBuilder: (context, index) {
                                  final ticket = tickets[index];

                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey.shade200,
                                      border: Border.all(
                                        color: Colors.blue.shade100,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 🔹 TOP ROW (Title + Pending badge)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                ticket['text']!,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            // 🔸 Pending Badge (Top-right)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                    horizontal: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.yellow.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.yellow.shade300,
                                                ),
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
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // 🔹 Timestamp
                                        Text(
                                          "Submitted: ${ticket['timestamp']}",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // BOTTOM BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Submit new ticket
                  Expanded(
                    child: ElevatedButton(
                      onPressed: handleAddTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Submit New Ticket",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // VIEW DETAILS BUTTON
                  if (tickets.isNotEmpty)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: goToTicketDescription,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "View Ticket Details",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
