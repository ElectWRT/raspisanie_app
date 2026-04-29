// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SubstitutionsTable extends Substitutions
    with TableInfo<$SubstitutionsTable, Substitution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubstitutionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _groupNameMeta =
      const VerificationMeta('groupName');
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
      'group_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _teacherMeta =
      const VerificationMeta('teacher');
  @override
  late final GeneratedColumn<String> teacher = GeneratedColumn<String>(
      'teacher', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
      'room', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, groupName, period, subject, teacher, room, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'substitutions';
  @override
  VerificationContext validateIntegrity(Insertable<Substitution> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('group_name')) {
      context.handle(_groupNameMeta,
          groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta));
    } else if (isInserting) {
      context.missing(_groupNameMeta);
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('teacher')) {
      context.handle(_teacherMeta,
          teacher.isAcceptableOrUnknown(data['teacher']!, _teacherMeta));
    } else if (isInserting) {
      context.missing(_teacherMeta);
    }
    if (data.containsKey('room')) {
      context.handle(
          _roomMeta, room.isAcceptableOrUnknown(data['room']!, _roomMeta));
    } else if (isInserting) {
      context.missing(_roomMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Substitution map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Substitution(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      teacher: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}teacher'])!,
      room: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SubstitutionsTable createAlias(String alias) {
    return $SubstitutionsTable(attachedDatabase, alias);
  }
}

class Substitution extends DataClass implements Insertable<Substitution> {
  final int id;
  final String groupName;
  final String period;
  final String subject;
  final String teacher;
  final String room;
  final DateTime createdAt;
  const Substitution(
      {required this.id,
      required this.groupName,
      required this.period,
      required this.subject,
      required this.teacher,
      required this.room,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_name'] = Variable<String>(groupName);
    map['period'] = Variable<String>(period);
    map['subject'] = Variable<String>(subject);
    map['teacher'] = Variable<String>(teacher);
    map['room'] = Variable<String>(room);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SubstitutionsCompanion toCompanion(bool nullToAbsent) {
    return SubstitutionsCompanion(
      id: Value(id),
      groupName: Value(groupName),
      period: Value(period),
      subject: Value(subject),
      teacher: Value(teacher),
      room: Value(room),
      createdAt: Value(createdAt),
    );
  }

  factory Substitution.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Substitution(
      id: serializer.fromJson<int>(json['id']),
      groupName: serializer.fromJson<String>(json['groupName']),
      period: serializer.fromJson<String>(json['period']),
      subject: serializer.fromJson<String>(json['subject']),
      teacher: serializer.fromJson<String>(json['teacher']),
      room: serializer.fromJson<String>(json['room']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupName': serializer.toJson<String>(groupName),
      'period': serializer.toJson<String>(period),
      'subject': serializer.toJson<String>(subject),
      'teacher': serializer.toJson<String>(teacher),
      'room': serializer.toJson<String>(room),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Substitution copyWith(
          {int? id,
          String? groupName,
          String? period,
          String? subject,
          String? teacher,
          String? room,
          DateTime? createdAt}) =>
      Substitution(
        id: id ?? this.id,
        groupName: groupName ?? this.groupName,
        period: period ?? this.period,
        subject: subject ?? this.subject,
        teacher: teacher ?? this.teacher,
        room: room ?? this.room,
        createdAt: createdAt ?? this.createdAt,
      );
  Substitution copyWithCompanion(SubstitutionsCompanion data) {
    return Substitution(
      id: data.id.present ? data.id.value : this.id,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      period: data.period.present ? data.period.value : this.period,
      subject: data.subject.present ? data.subject.value : this.subject,
      teacher: data.teacher.present ? data.teacher.value : this.teacher,
      room: data.room.present ? data.room.value : this.room,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Substitution(')
          ..write('id: $id, ')
          ..write('groupName: $groupName, ')
          ..write('period: $period, ')
          ..write('subject: $subject, ')
          ..write('teacher: $teacher, ')
          ..write('room: $room, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, groupName, period, subject, teacher, room, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Substitution &&
          other.id == this.id &&
          other.groupName == this.groupName &&
          other.period == this.period &&
          other.subject == this.subject &&
          other.teacher == this.teacher &&
          other.room == this.room &&
          other.createdAt == this.createdAt);
}

class SubstitutionsCompanion extends UpdateCompanion<Substitution> {
  final Value<int> id;
  final Value<String> groupName;
  final Value<String> period;
  final Value<String> subject;
  final Value<String> teacher;
  final Value<String> room;
  final Value<DateTime> createdAt;
  const SubstitutionsCompanion({
    this.id = const Value.absent(),
    this.groupName = const Value.absent(),
    this.period = const Value.absent(),
    this.subject = const Value.absent(),
    this.teacher = const Value.absent(),
    this.room = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SubstitutionsCompanion.insert({
    this.id = const Value.absent(),
    required String groupName,
    required String period,
    required String subject,
    required String teacher,
    required String room,
    this.createdAt = const Value.absent(),
  })  : groupName = Value(groupName),
        period = Value(period),
        subject = Value(subject),
        teacher = Value(teacher),
        room = Value(room);
  static Insertable<Substitution> custom({
    Expression<int>? id,
    Expression<String>? groupName,
    Expression<String>? period,
    Expression<String>? subject,
    Expression<String>? teacher,
    Expression<String>? room,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupName != null) 'group_name': groupName,
      if (period != null) 'period': period,
      if (subject != null) 'subject': subject,
      if (teacher != null) 'teacher': teacher,
      if (room != null) 'room': room,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SubstitutionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? groupName,
      Value<String>? period,
      Value<String>? subject,
      Value<String>? teacher,
      Value<String>? room,
      Value<DateTime>? createdAt}) {
    return SubstitutionsCompanion(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      period: period ?? this.period,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      room: room ?? this.room,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (teacher.present) {
      map['teacher'] = Variable<String>(teacher.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubstitutionsCompanion(')
          ..write('id: $id, ')
          ..write('groupName: $groupName, ')
          ..write('period: $period, ')
          ..write('subject: $subject, ')
          ..write('teacher: $teacher, ')
          ..write('room: $room, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubstitutionsTable substitutions = $SubstitutionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [substitutions];
}

typedef $$SubstitutionsTableCreateCompanionBuilder = SubstitutionsCompanion
    Function({
  Value<int> id,
  required String groupName,
  required String period,
  required String subject,
  required String teacher,
  required String room,
  Value<DateTime> createdAt,
});
typedef $$SubstitutionsTableUpdateCompanionBuilder = SubstitutionsCompanion
    Function({
  Value<int> id,
  Value<String> groupName,
  Value<String> period,
  Value<String> subject,
  Value<String> teacher,
  Value<String> room,
  Value<DateTime> createdAt,
});

class $$SubstitutionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubstitutionsTable> {
  $$SubstitutionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teacher => $composableBuilder(
      column: $table.teacher, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SubstitutionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubstitutionsTable> {
  $$SubstitutionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teacher => $composableBuilder(
      column: $table.teacher, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SubstitutionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubstitutionsTable> {
  $$SubstitutionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get teacher =>
      $composableBuilder(column: $table.teacher, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SubstitutionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubstitutionsTable,
    Substitution,
    $$SubstitutionsTableFilterComposer,
    $$SubstitutionsTableOrderingComposer,
    $$SubstitutionsTableAnnotationComposer,
    $$SubstitutionsTableCreateCompanionBuilder,
    $$SubstitutionsTableUpdateCompanionBuilder,
    (
      Substitution,
      BaseReferences<_$AppDatabase, $SubstitutionsTable, Substitution>
    ),
    Substitution,
    PrefetchHooks Function()> {
  $$SubstitutionsTableTableManager(_$AppDatabase db, $SubstitutionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubstitutionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubstitutionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubstitutionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> groupName = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String> teacher = const Value.absent(),
            Value<String> room = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SubstitutionsCompanion(
            id: id,
            groupName: groupName,
            period: period,
            subject: subject,
            teacher: teacher,
            room: room,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String groupName,
            required String period,
            required String subject,
            required String teacher,
            required String room,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SubstitutionsCompanion.insert(
            id: id,
            groupName: groupName,
            period: period,
            subject: subject,
            teacher: teacher,
            room: room,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SubstitutionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubstitutionsTable,
    Substitution,
    $$SubstitutionsTableFilterComposer,
    $$SubstitutionsTableOrderingComposer,
    $$SubstitutionsTableAnnotationComposer,
    $$SubstitutionsTableCreateCompanionBuilder,
    $$SubstitutionsTableUpdateCompanionBuilder,
    (
      Substitution,
      BaseReferences<_$AppDatabase, $SubstitutionsTable, Substitution>
    ),
    Substitution,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubstitutionsTableTableManager get substitutions =>
      $$SubstitutionsTableTableManager(_db, _db.substitutions);
}
