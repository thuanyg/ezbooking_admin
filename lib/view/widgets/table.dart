import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:ezbooking_admin/core/configs/app_colors.dart';
import 'package:ezbooking_admin/models/order.dart';
import 'package:flutter/material.dart';

class EventStatisticsTable extends StatelessWidget {
  final List<Order> orders;

  const EventStatisticsTable({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final orderSuccess = orders.where((o)=>o.status == "success").toList();
    List<EventStat> eventStats = _getEventStatistics(orderSuccess);
    eventStats.sort((a, b) => b.totalAttendees.compareTo(a.totalAttendees));
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Top Events by Number of Attendees',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Bảng hiển thị thống kê
          FutureBuilder<List<EventStat>>(
            future: _fetchEventNames(eventStats), // Fetch event names here
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ); // Show loading indicator while fetching
              }
              if (snapshot.hasError) {
                return const Text('Error fetching event names');
              }

              final eventsWithNames = snapshot.data ?? [];

              return DataTable(
                columns: const [
                  DataColumn(
                    label: Text(
                      'Event Name',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Total Attendees',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
                rows: eventsWithNames.map((stat) {
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        stat.eventName,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white60,
                        ),
                      )),
                      DataCell(Text(
                        stat.totalAttendees.toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white60,
                        ),
                      )),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // Hàm tính toán số lượng người tham gia cho mỗi sự kiện
  List<EventStat> _getEventStatistics(List<Order> orders) {
    Map<String, int> eventAttendeesMap = {};

    // Tính tổng số lượng người tham gia cho mỗi sự kiện
    for (var order in orders) {
      if (eventAttendeesMap.containsKey(order.eventID)) {
        eventAttendeesMap[order.eventID] =
            eventAttendeesMap[order.eventID]! + order.ticketQuantity;
      } else {
        eventAttendeesMap[order.eventID] = order.ticketQuantity;
      }
    }

    // Chuyển đổi map thành list các sự kiện
    return eventAttendeesMap.entries
        .map((entry) => EventStat(
            eventId: entry.key, eventName: "", totalAttendees: entry.value))
        .toList();
  }

  // Fetch event names from Firestore
  Future<List<EventStat>> _fetchEventNames(List<EventStat> eventStats) async {
    final eventNames = <EventStat>[];

    for (var eventStat in eventStats) {
      try {
        // Fetch the event name from Firestore using eventID from Order
        cf.DocumentSnapshot eventDoc = await cf.FirebaseFirestore.instance
            .collection('events')
            .doc(eventStat.eventId)
            .get();

        if (eventDoc.exists) {
          if (eventDoc['isDelete'] == true) continue;
          String eventName = eventDoc[
              'name']; // Assuming 'name' is the field holding the event name
          eventNames.add(EventStat(
              eventId: eventStat.eventId,
              eventName: eventName,
              totalAttendees: eventStat.totalAttendees));
        }
      } catch (e) {
        print('Error fetching event name: $e');
      }
    }

    return eventNames;
  }
}

// Lớp dữ liệu thống kê sự kiện
class EventStat {
  final String eventName; // Changed to eventName
  final int totalAttendees;
  final String eventId;

  EventStat(
      {required this.eventName,
      required this.totalAttendees,
      required this.eventId});
}
