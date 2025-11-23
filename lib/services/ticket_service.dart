import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_model.dart';

class TicketService {
  static final _ticketsRef = FirebaseFirestore.instance.collection("tickets");

  // LIST PENDING JOBS FOR PROFESSIONALS
  static Stream<List<Ticket>> getPendingJobs() {
    return _ticketsRef
        .where("status", isEqualTo: "pending")
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Ticket.fromDoc(d.id, d.data())).toList(),
        );
  }

  // ACCEPT A JOB
  static Future<void> acceptJob(String ticketId, String professionalId) async {
    await FirebaseFirestore.instance.collection("tickets").doc(ticketId).update(
      {"status": "in_progress", "professionalId": professionalId},
    );
  }

  // COMPLETE JOB
  static Future<void> completeJob(String ticketId) async {
    await _ticketsRef.doc(ticketId).update({"status": "done"});
  }

  // JOBS ASSIGNED TO A SPECIFIC PROFESSIONAL
  static Stream<List<Ticket>> getMyJobs(String professionalId) {
    return _ticketsRef
        .where("professionalId", isEqualTo: professionalId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Ticket.fromDoc(d.id, d.data())).toList(),
        );
  }

  static Future<void> addTicket(Ticket ticket) async {
    await _ticketsRef.add(ticket.toMap());
  }

  static Stream<List<Ticket>> getTicketsForUser(String userId) {
    return _ticketsRef
        .where("userId", isEqualTo: userId)
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => Ticket.fromDoc(doc.id, doc.data()))
              .toList();
        });
  }

  static Stream<List<Ticket>> getTicketsByCategory(
    String userId,
    String? category,
  ) {
    var query = _ticketsRef
        .where("userId", isEqualTo: userId)
        .orderBy("timestamp", descending: true);

    if (category != null && category != "All") {
      query = query.where("category", isEqualTo: category);
    }

    return query.snapshots().map(
      (snap) => snap.docs.map((d) => Ticket.fromDoc(d.id, d.data())).toList(),
    );
  }
}
