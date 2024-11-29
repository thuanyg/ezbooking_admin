import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:ezbooking_admin/models/event.dart';
import 'package:ezbooking_admin/models/organizer.dart';
import 'package:ezbooking_admin/models/ticket.dart';
import 'package:ezbooking_admin/models/user.dart';
import 'package:flutter/material.dart';
import 'package:ezbooking_admin/models/order.dart';

class StatisticProvider with ChangeNotifier {
  final cf.FirebaseFirestore firebaseFirestore = cf.FirebaseFirestore.instance;
  bool isLoading = false;
  List<Statistic> statistics = [];

  List<Order> getOrders(List<Statistic> statistics) {
    List<Order> orders = [];
    for (var statistic in statistics) {
      orders.add(statistic.order);
    }
    return orders;
  }

  int calculateTicketToday(List<Order> orders) {
    final today = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 7)); // Vietnam timezone (UTC +7)
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)); // End of the day

    return orders.fold(0, (count, order) {
      // Check if the order's createdAt is today
      if (order.createdAt.toDate().isAfter(startOfDay) &&
          order.createdAt.toDate().isBefore(endOfDay)) {
        // Ensure ticketQuantity is non-null and add it to the count
        return count + (order.ticketQuantity);
      }
      return count;
    });
  }

  Future<List<Statistic>> fetchStatistics() async {
    isLoading = true;
    notifyListeners();

    try {
      // Fetch all tickets from Firestore
      final querySnapshot = await firebaseFirestore.collection('tickets').get();

      // List to hold the resulting statistics
      List<Statistic> statistics = [];

      // Iterate over each ticket document
      for (var ticket in querySnapshot.docs) {
        final ticketModel = Ticket.fromFirestore(ticket.data(), ticket.id);

        // Use Future.wait to fetch related data concurrently
        final futures = [
          firebaseFirestore.collection('orders').doc(ticketModel.orderID).get(),
          firebaseFirestore.collection('users').doc(ticketModel.userID).get(),
          firebaseFirestore.collection('events').doc(ticketModel.eventID).get(),

        ];

        // Wait for all the futures to complete
        final responses = await Future.wait(futures);
        // Map the responses to models
        final orderModel = Order.fromFirestore(
            responses[0].data() as Map<String, dynamic>, responses[0].id);
        final userModel =
            UserModel.fromJson(responses[1].data() as Map<String, dynamic>);

        final eventModel =
            Event.fromJson(responses[2].data() as Map<String, dynamic>);


        final orgDocs = await firebaseFirestore
            .collection('organizers')
            .doc(eventModel.organizer ?? "")
            .get();


        final organizer =
            Organizer.fromJson(orgDocs.data() as Map<String, dynamic>);

        // Create the Statistic object
        final statistic = Statistic(
          order: orderModel,
          ticket: ticketModel,
          user: userModel,
          event: eventModel,
          organizer: organizer,
        );

        // Add to the list of statistics
        statistics.add(statistic);
      }

      this.statistics = statistics;

      return statistics;
    } catch (e) {
      print("Error fetching statistics: $e");
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class Statistic {
  final Order order;
  final Ticket ticket;
  final UserModel user;
  final Organizer organizer;
  final Event event;

  Statistic({
    required this.order,
    required this.ticket,
    required this.user,
    required this.event,
    required this.organizer,
  });
}
