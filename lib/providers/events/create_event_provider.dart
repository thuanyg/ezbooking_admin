import 'package:ezbooking_admin/datasource/events/event_datasource.dart';
import 'package:ezbooking_admin/models/event.dart';
import 'package:flutter/material.dart';

class CreateEventProvider with ChangeNotifier{
  bool isLoading = false;
  bool isSuccess = false;
  Event? event;
  final EventDatasource _datasource;

  CreateEventProvider(this._datasource);

  Future<void> createEvent(Event event) async {
    try {
      isLoading = true;
      notifyListeners();
      await _datasource.createEvent(event);
      this.event = event;
      isLoading = false;
      isSuccess = true;
      notifyListeners();
    } on Exception catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}