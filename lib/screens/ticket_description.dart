import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../models/ticket_model.dart';

class TicketDescriptionScreen extends StatelessWidget {
  final List<Ticket> tickets;

  const TicketDescriptionScreen({Key? key, required this.tickets})
    : super(key: key);

  // Categories and prices mapped for auto-detection
  static const jobCategories = [
    {'title': 'Cleaning the house', 'price': '\$75 - 100'},
    {'title': 'Plumbing repair', 'price': '\$120 - 180'},
    {'title': 'Washing cars', 'price': '\$40 - 60'},
    {'title': 'Electrical wiring check', 'price': '\$150 - 200'},
    {'title': 'Garden maintenance', 'price': '\$60 - 90'},
    {'title': 'Moving Furniture', 'price': '\$100 - 150'},
    {'title': 'Furniture Polishing', 'price': '\$30 - 40'},
    {'title': 'Organizing storage rooms or garages', 'price': '\$20 - 50'},
    {'title': 'Replacing broken toilet', 'price': '\$20 - 30'},
    {'title': 'Installing new sink', 'price': '\$50 - 80'},
    {'title': 'Repairing washing machine', 'price': '\$20 - 25'},
    {'title': 'Refrigerator Repair', 'price': '\$10 - 15'},
    {'title': 'Cleaning office desks and windows', 'price': '\$20 - 40'},
    {'title': 'Repainting walls', 'price': '\$200 - 300'},
    {'title': 'Lawn mowing', 'price': '\$10 - 15'},
    {'title': 'Tree trimming', 'price': '\$50 - 70'},
    {'title': 'Garden fence painting', 'price': '\$100 - 150'},
    {'title': 'Plant watering and care', 'price': '\$10 - 12'},
  ];

  // Finds the category based on ticket text
  String findCategory(String ticketName) {
    for (var job in jobCategories) {
      if (ticketName.toLowerCase().contains(job['title']!.toLowerCase())) {
        return job['title']!;
      }
    }
    return "Unknown Category";
  }

  // Derives priority based on price range
  String derivePriority(String category) {
    final job = jobCategories.firstWhere(
      (e) => e['title']!.toLowerCase() == category.toLowerCase(),
      orElse: () => {'price': '\$0 - 0'},
    );

    final price = job['price']!.replaceAll("\$", "").split('-');
    final minPrice = int.tryParse(price[0].trim()) ?? 0;

    if (minPrice <= 30) return "Easy";
    if (minPrice <= 90) return "Medium";
    return "Hard";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Ticket Details"),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final t = tickets[index];
            final category = findCategory(t.text);
            final priority = derivePriority(category);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BLUE HEADER SECTION
                  Container(
                    height: 60,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      t.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 Pending Status Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 14,
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

                  const SizedBox(height: 16),

                  // 🔹 Description Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Text(
                      "No additional description provided.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 Category Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Category",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 Priority Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Priority",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Text(
                      priority,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 Timestamp at bottom (FIXED)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Submitted on: ${t.timestamp}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
