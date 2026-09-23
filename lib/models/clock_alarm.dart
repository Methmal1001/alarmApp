import 'package:flutter/material.dart';

class ClockAlarm {
  ClockAlarm({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    this.repeatDays = const <int>{},
    this.isActive = true,
  });

  final String id;
  String label;
  int hour;
  int minute;
  Set<int> repeatDays; // 1 = Monday ... 7 = Sunday (DateTime weekday values)
  bool isActive;

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  bool get isRepeating => repeatDays.isNotEmpty;

  String repeatLabel() {
    if (repeatDays.isEmpty) return 'Once';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (repeatDays.length == 7) return 'Every day';
    final weekdays = {1, 2, 3, 4, 5};
    final weekend = {6, 7};
    if (repeatDays.containsAll(weekdays) && repeatDays.length == 5) return 'Weekdays';
    if (repeatDays.containsAll(weekend) && repeatDays.length == 2) return 'Weekends';
    final sorted = repeatDays.toList()..sort();
    return sorted.map((d) => names[d - 1]).join(', ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'hour': hour,
        'minute': minute,
        'repeatDays': repeatDays.toList(),
        'isActive': isActive,
      };

  factory ClockAlarm.fromJson(Map<String, dynamic> json) => ClockAlarm(
        id: json['id'] as String,
        label: json['label'] as String,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        repeatDays: (json['repeatDays'] as List).map((e) => e as int).toSet(),
        isActive: json['isActive'] as bool,
      );
}
