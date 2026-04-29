import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

part 'database.g.dart';

class BaseSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get groupName => text()();
  IntColumn get dayOfWeek => integer()(); // 1-7
  IntColumn get pairNumber => integer()();
  TextColumn get subject => text()();
  TextColumn get teacher => text()();
  TextColumn get room => text()();
}

class Substitutions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get groupName => text()();
  IntColumn get pairNumber => integer()();
  TextColumn get subject => text()();
  TextColumn get teacher => text()();
  TextColumn get room => text()();
}

@DriftDatabase(tables: [BaseSchedules, Substitutions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // New CRUD methods for Repository
  Future<List<Substitution>> getAllSubstitutions() => select(substitutions).get();
  Stream<List<Substitution>> watchAllSubstitutions() => select(substitutions).watch();
  Future<void> clearAllSubstitutions() => delete(substitutions).go();
  
  Future<void> insertSubstitutions(List<SubstitutionsCompanion> items) async {
    await batch((batch) {
      batch.insertAll(substitutions, items, mode: InsertMode.insertOrReplace);
    });
  }

  // Unified Stream: Merges base schedule with substitutions
  Stream<List<UnifiedScheduleItem>> watchUnifiedSchedule(String group, int dayOfWeek, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    
    // We fetch base schedule and substitutions for the date
    final baseQuery = select(baseSchedules)..where((t) => t.groupName.equals(group) & t.dayOfWeek.equals(dayOfWeek));
    final subQuery = select(substitutions)..where((t) => t.groupName.equals(group) & t.date.equals(startOfDay));

    return Rx.combineLatest2(baseQuery.watch(), subQuery.watch(), (baseList, subList) {
      final List<UnifiedScheduleItem> result = [];
      
      // Map subs by pair number for quick lookup
      final subsMap = {for (var s in subList) s.pairNumber: s};

      for (var base in baseList) {
        final sub = subsMap[base.pairNumber];
        if (sub != null) {
          result.add(UnifiedScheduleItem(
            pairNumber: base.pairNumber,
            subject: sub.subject,
            teacher: sub.teacher,
            room: sub.room,
            isSubstitution: true,
            originalSubject: base.subject,
          ));
          subsMap.remove(base.pairNumber);
        } else {
          result.add(UnifiedScheduleItem(
            pairNumber: base.pairNumber,
            subject: base.subject,
            teacher: base.teacher,
            room: base.room,
            isSubstitution: false,
          ));
        }
      }

      // Add substitutions that don't have a base pair (e.g. extra pair)
      for (var sub in subsMap.values) {
        result.add(UnifiedScheduleItem(
          pairNumber: sub.pairNumber,
          subject: sub.subject,
          teacher: sub.teacher,
          room: sub.room,
          isSubstitution: true,
        ));
      }

      result.sort((a, b) => a.pairNumber.compareTo(b.pairNumber));
      return result;
    });
  }
}

class UnifiedScheduleItem {
  final int pairNumber;
  final String subject;
  final String teacher;
  final String room;
  final bool isSubstitution;
  final String? originalSubject;

  UnifiedScheduleItem({
    required this.pairNumber,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.isSubstitution,
    this.originalSubject,
  });
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
