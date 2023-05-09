import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Event {
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final Color color;
  final bool isAllDay;

  const Event({
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    this.color = Colors.orangeAccent,
    this.isAllDay = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'start': start,
      'end': end,
      'isAllDay': isAllDay,
    };
  }
}

class EventUtility {
  static String toDateTime(DateTime dateTime) {
    final date = DateFormat.yMMMEd().format(dateTime);
    final time = DateFormat.Hm().format(dateTime);
    return '$date $time';
  }

  static String toDate(DateTime dateTime) {
    return DateFormat.yMMMEd().format(dateTime);
  }

  static String toTime(DateTime dateTime) {
    return DateFormat.Hm().format(dateTime);
  }

  static DateTime removeTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}

class EventManager extends ChangeNotifier {
  final List<Event> _events = [];

  EventManager() {
    //getEventsFromFirebase();
  }

  List<Event> get events  {
    return [..._events];
  }

  void addEvent(Event event) {
    _events.add(event);
    FirebaseFirestore.instance.collection('Events').add(event.toMap());
    notifyListeners();
  }

  void removeEvent(Event event) {
    _events.remove(event);
    notifyListeners();
  }

  void updateEvent(Event event) {
    final index = _events.indexOf(event);
    _events[index] = event;
    notifyListeners();
  }

  Future<List<Event>> getEventsFromFirebase() async {
    _events.clear();
    await FirebaseFirestore.instance.collection('Events').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        _events.add(Event(
          title: doc['title'],
          description: doc['description'],
          start: doc['start'].toDate(),
          end: doc['end'].toDate(),
          isAllDay: doc['isAllDay'],
        ));
      }
    });
    return _events;
  }
}