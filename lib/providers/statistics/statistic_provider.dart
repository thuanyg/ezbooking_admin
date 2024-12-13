import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:ezbooking_admin/models/ticket.dart';
import 'package:flutter/material.dart';
import 'package:ezbooking_admin/models/order.dart';

class StatisticProvider with ChangeNotifier {
  final cf.FirebaseFirestore firebaseFirestore = cf.FirebaseFirestore.instance;
  bool isLoading = false;
  List<Order> orders = [];

  Future<void> fetchOrders() async {
    isLoading = true;
    notifyListeners();

    try {
      // Fetch all orders
      final orderSnapshot = await firebaseFirestore.collection('orders').get();

      // Map orders to a list
      orders = orderSnapshot.docs.map((doc) {
        return Order.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching orders: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  int countTicketsSoldToday(List<Order> orders) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Filter orders created today
    final todayOrders = orders.where((order) {
      final createdAt = order.createdAt.toDate();
      return createdAt.isAfter(startOfDay) && createdAt.isBefore(endOfDay);
    });

    // Count tickets from today's orders
    int totalTicketsSold =
        todayOrders.fold(0, (total, order) => total + order.ticketQuantity);

    return totalTicketsSold;
  }
}
