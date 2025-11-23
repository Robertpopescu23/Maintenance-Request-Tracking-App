class Ticket {
  final String id;
  final String text;
  final String timestamp;
  final String userId;
  final String category;
  final String status; // pending / in_progress / done
  final String? professionalId; // nullable

  Ticket({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.userId,
    required this.category,
    required this.status,
    this.professionalId,
  });

  // REQUIRED: used by TicketService & AcceptedJobsScreen
  factory Ticket.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Ticket(
      id: documentId,
      text: data["text"] ?? "",
      timestamp: data["timestamp"] ?? "",
      userId: data["userId"] ?? "",
      status: data["status"] ?? "pending",
      category: data["category"] ?? "",
      professionalId: data["professionalId"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "timestamp": timestamp,
      "userId": userId,
      "category": category,
      "status": status,
      "professionalId": professionalId,
    };
  }

  static Ticket fromDoc(String id, Map<String, dynamic> data) {
    return Ticket(
      id: id,
      text: data["text"] ?? "",
      timestamp: data["timestamp"] ?? "",
      userId: data["userId"] ?? "",
      category: data["category"] ?? "uncategorized",
      status: data["status"] ?? "pending",
      professionalId: data["professionalId"],
    );
  }
}
