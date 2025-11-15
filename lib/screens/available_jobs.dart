import 'package:flutter/material.dart';
import 'verify_your_account.dart';

class AvailableJobsScreen extends StatelessWidget {
  const AvailableJobsScreen({Key? key}) : super(key: key);

  // Example list of available jobs
  final List<Map<String, String>> jobs = const [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Available Jobs Box
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
                      // Top 1/4 section (light green background)
                      Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.lightGreen,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Available Jobs',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.map, color: Colors.white, size: 28),
                          ],
                        ),
                      ),

                      // Job list area
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: jobs.length,
                          itemBuilder: (context, index) {
                            final job = jobs[index];
                            final bool isAvailable = index % 2 != 0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title and price row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          job['title']!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        job['price']!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // Availability status box
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAvailable
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isAvailable
                                          ? 'Available'
                                          : 'Not Available',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
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

              // GO TO VERIFICATION BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerifyYourAccountScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen, // background
                    foregroundColor: Colors.white, // text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Go to Verification',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
