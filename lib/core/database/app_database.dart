import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Substitutions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get groupName => text()();
  TextColumn get period => text()();
  TextColumn get subject => text()();
  TextColumn get teacher => text()();
  TextColumn get room => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Substitutions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // DAOs or methods
  Future<List<Substitution>> getAllSubstitutions() => select(substitutions).get();
  
  Stream<List<Substitution>> watchAllSubstitutions() => select(substitutions).watch();

  Future<void> insertSubstitutions(List<SubstitutionsCompanion> items) async {
    await batch((batch) {
      batch.insertAll(substitutions, items, mode: InsertMode.insertOrReplace);
    });
  }

  Future<void> clearAll() => delete(substitutions).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
