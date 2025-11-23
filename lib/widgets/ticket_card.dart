import 'package:flutter/material.dart';

class TicketCard extends StatelessWidget {
  final String title;
  final String timestamp;
  final String status;
  final VoidCallback? onTap;

  const TicketCard({
    super.key,
    required this.title,
    required this.timestamp,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              timestamp,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    String label;
    Color bg;
    Color textColor;

    if (status == 'in_progress') {
      label = 'In Progress';
      bg = Colors.green; // green background
      textColor = Colors.yellowAccent; // yellow text
    } else if (status == 'done') {
      label = 'Done';
      bg = Colors.blue;
      textColor = Colors.white;
    } else {
      // default: pending
      label = 'Pending';
      bg = Colors.yellow.shade200;
      textColor = Colors.brown;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
