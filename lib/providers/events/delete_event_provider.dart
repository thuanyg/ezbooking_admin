import 'package:ezbooking_admin/datasource/events/event_datasource.dart';
import 'package:ezbooking_admin/models/event.dart';
import 'package:flutter/material.dart';

class DeleteEventProvider with ChangeNotifier{
  bool isLoading = false;
  bool isSuccess = false;
  Event? event;
  final EventDatasource _datasource;

  DeleteEventProvider(this._datasource);

  Future<void> deleteEvent(Event event) async {
    try {
      isLoading = true;
      notifyListeners();
      await _datasource.deleteEvent(event);
      this.event = event;
      isLoading = false;
      isSuccess = true;
      notifyListeners();
    } on Exception catch (e) {
      print(e);
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}