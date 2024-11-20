import 'package:ezbooking_admin/datasource/events/event_datasource.dart';
import 'package:ezbooking_admin/models/event.dart';
import 'package:ezbooking_admin/view/widgets/event_edit.dart';
import 'package:flutter/material.dart';

class FetchEventsProvider with ChangeNotifier {
  List<Event> events = [];
  bool isLoading = false;
  final EventDatasource _datasource;

  FetchEventsProvider(this._datasource);

  Future<void> fetchEvents() async {
    try {
      isLoading = true;
      notifyListeners();
      List<Event> events = await _datasource.fetchEvents();
      this.events = events;
      isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      print(e);
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  updateEvents(Event? event, ActionType type) {
    if (event != null) {
      final index = events.indexWhere((e) => e.id == event.id);
      if (type == ActionType.update && index != -1) {
        events[index] = event;
      }
      if(type == ActionType.create){
        events.add(event);
      }
      if(type == ActionType.delete){
        events.removeAt(index);
      }
      notifyListeners();
    }
  }
}
