import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart';
import '../../core/database/database.dart';

class DatabaseInitializer {
  final AppDatabase database;

  DatabaseInitializer(this.database);

  Future<void> initializeBaseSchedule() async {
    final count = await (database.select(database.baseSchedules)..limit(1)).get();
    if (count.isNotEmpty) return; // Already initialized

    try {
      final String response = await rootBundle.loadString('assets/base_schedule.json');
      final List<dynamic> data = json.decode(response);
      
      await database.batch((batch) {
        batch.insertAll(
          database.baseSchedules,
          data.map((json) => BaseSchedulesCompanion.insert(
            groupName: json['groupName'],
            dayOfWeek: json['dayOfWeek'],
            pairNumber: json['pairNumber'],
            subject: json['subject'],
            teacher: json['teacher'],
            room: json['room'],
          )).toList(),
        );
      });
    } catch (e) {
      print('Database Initialization Error: $e');
    }
  }
}
