import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezbooking_admin/models/event.dart';

class EventDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createEvent(Event event) async {
    try {
      await _firestore.collection("events").doc(event.id).set(event.toMap());
    } on Exception {
      rethrow;
    }
  }

  Future<void> deleteEvent(Event event) async {
    try {
      final doc = _firestore.collection("events").doc(event.id);
      doc.delete();
    } on Exception {
      rethrow;
    }
  }

  Future<List<Event>> fetchEvents() async {
    try {
      final docs = await _firestore.collection("events").orderBy("date", descending: true).get();

      return docs.docs.map((doc) {
        return Event.fromJson(doc.data(), id: doc.id);
      }).toList();
    } on Exception catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      final doc = _firestore.collection("events").doc(event.id);
      doc.update(event.toMap());
    } on Exception catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}
