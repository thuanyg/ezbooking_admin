import 'package:ezbooking_admin/models/event.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Giả sử bạn dùng Firebase Firestore

class FetchEventProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Event? _event;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Event? get event => _event;

  // Hàm fetch sự kiện theo ID từ Firestore
  Future<void> fetchEventById(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Thông báo thay đổi trạng thái
    try {
      // Lấy sự kiện từ Firestore (hoặc nguồn dữ liệu khác)
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('events').doc(eventId).get();


      // Kiểm tra nếu sự kiện tồn tại
      if (snapshot.exists) {
        // Chuyển đổi dữ liệu từ Firestore thành model Event
        _event = Event.fromJson(snapshot.data() as Map<String, dynamic>);
      } else {
        _error = "Event not found";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Thông báo khi tải xong
    }
  }
}
