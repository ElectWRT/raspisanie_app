// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BaseSchedulesTable extends BaseSchedules
    with TableInfo<$BaseSchedulesTable, BaseSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BaseSchedulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dayOfWeekMeta =
      const VerificationMeta('dayOfWeek');
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
      'day_of_week', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pairNumberMeta =
      const VerificationMeta('pairNumber');
  @override
  late final GeneratedColumn<int> pairNumber = GeneratedColumn<int>(
      'pair_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, groupName, dayOfWeek, pairNumber, subject, teacher, room];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'base_schedules';
  @override
  VerificationContext validateIntegrity(Insertable<BaseSchedule> instance,
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
    if (data.containsKey('day_of_week')) {
      context.handle(
          _dayOfWeekMeta,
          dayOfWeek.isAcceptableOrUnknown(
              data['day_of_week']!, _dayOfWeekMeta));
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('pair_number')) {
      context.handle(
          _pairNumberMeta,
          pairNumber.isAcceptableOrUnknown(
              data['pair_number']!, _pairNumberMeta));
    } else if (isInserting) {
      context.missing(_pairNumberMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BaseSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BaseSchedule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name'])!,
      dayOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_week'])!,
      pairNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pair_number'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      teacher: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}teacher'])!,
      room: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room'])!,
    );
  }

  @override
  $BaseSchedulesTable createAlias(String alias) {
    return $BaseSchedulesTable(attachedDatabase, alias);
  }
}

class BaseSchedule extends DataClass implements Insertable<BaseSchedule> {
  final int id;
  final String groupName;
  final int dayOfWeek;
  final int pairNumber;
  final String subject;
  final String teacher;
  final String room;
  const BaseSchedule(
      {required this.id,
      required this.groupName,
      required this.dayOfWeek,
      required this.pairNumber,
      required this.subject,
      required this.teacher,
      required this.room});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_name'] = Variable<String>(groupName);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['pair_number'] = Variable<int>(pairNumber);
    map['subject'] = Variable<String>(subject);
    map['teacher'] = Variable<String>(teacher);
    map['room'] = Variable<String>(room);
    return map;
  }

  BaseSchedulesCompanion toCompanion(bool nullToAbsent) {
    return BaseSchedulesCompanion(
      id: Value(id),
      groupName: Value(groupName),
      dayOfWeek: Value(dayOfWeek),
      pairNumber: Value(pairNumber),
      subject: Value(subject),
      teacher: Value(teacher),
      room: Value(room),
    );
  }

  factory BaseSchedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BaseSchedule(
      id: serializer.fromJson<int>(json['id']),
      groupName: serializer.fromJson<String>(json['groupName']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      pairNumber: serializer.fromJson<int>(json['pairNumber']),
      subject: serializer.fromJson<String>(json['subject']),
      teacher: serializer.fromJson<String>(json['teacher']),
      room: serializer.fromJson<String>(json['room']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupName': serializer.toJson<String>(groupName),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'pairNumber': serializer.toJson<int>(pairNumber),
      'subject': serializer.toJson<String>(subject),
      'teacher': serializer.toJson<String>(teacher),
      'room': serializer.toJson<String>(room),
    };
  }

  BaseSchedule copyWith(
          {int? id,
          String? groupName,
          int? dayOfWeek,
          int? pairNumber,
          String? subject,
          String? teacher,
          String? room}) =>
      BaseSchedule(
        id: id ?? this.id,
        groupName: groupName ?? this.groupName,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        pairNumber: pairNumber ?? this.pairNumber,
        subject: subject ?? this.subject,
        teacher: teacher ?? this.teacher,
        room: room ?? this.room,
      );
  BaseSchedule copyWithCompanion(BaseSchedulesCompanion data) {
    return BaseSchedule(
      id: data.id.present ? data.id.value : this.id,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      pairNumber:
          data.pairNumber.present ? data.pairNumber.value : this.pairNumber,
      subject: data.subject.present ? data.subject.value : this.subject,
      teacher: data.teacher.present ? data.teacher.value : this.teacher,
      room: data.room.present ? data.room.value : this.room,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BaseSchedule(')
          ..write('id: $id, ')
          ..write('groupName: $groupName, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('pairNumber: $pairNumber, ')
          ..write('subject: $subject, ')
          ..write('teacher: $teacher, ')
          ..write('room: $room')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, groupName, dayOfWeek, pairNumber, subject, teacher, room);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BaseSchedule &&
          other.id == this.id &&
          other.groupName == this.groupName &&
          other.dayOfWeek == this.dayOfWeek &&
          other.pairNumber == this.pairNumber &&
          other.subject == this.subject &&
          other.teacher == this.teacher &&
          other.room == this.room);
}

class BaseSchedulesCompanion extends UpdateCompanion<BaseSchedule> {
  final Value<int> id;
  final Value<String> groupName;
  final Value<int> dayOfWeek;
  final Value<int> pairNumber;
  final Value<String> subject;
  final Value<String> teacher;
  final Value<String> room;
  const BaseSchedulesCompanion({
    this.id = const Value.absent(),
    this.groupName = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.pairNumber = const Value.absent(),
    this.subject = const Value.absent(),
    this.teacher = const Value.absent(),
    this.room = const Value.absent(),
  });
  BaseSchedulesCompanion.insert({
    this.id = const Value.absent(),
    required String groupName,
    required int dayOfWeek,
    required int pairNumber,
    required String subject,
    required String teacher,
    required String room,
  })  : groupName = Value(groupName),
        dayOfWeek = Value(dayOfWeek),
        pairNumber = Value(pairNumber),
        subject = Value(subject),
        teacher = Value(teacher),
        room = Value(room);
  static Insertable<BaseSchedule> custom({
    Expression<int>? id,
    Expression<String>? groupName,
    Expression<int>? dayOfWeek,
    Expression<int>? pairNumber,
    Expression<String>? subject,
    Expression<String>? teacher,
    Expression<String>? room,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupName != null) 'group_name': groupName,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (pairNumber != null) 'pair_number': pairNumber,
      if (subject != null) 'subject': subject,
      if (teacher != null) 'teacher': teacher,
      if (room != null) 'room': room,
    });
  }

  BaseSchedulesCompanion copyWith(
      {Value<int>? id,
      Value<String>? groupName,
      Value<int>? dayOfWeek,
      Value<int>? pairNumber,
      Value<String>? subject,
      Value<String>? teacher,
      Value<String>? room}) {
    return BaseSchedulesCompanion(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      pairNumber: pairNumber ?? this.pairNumber,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      room: room ?? this.room,
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
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (pairNumber.present) {
      map['pair_number'] = Variable<int>(pairNumber.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BaseSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('groupName: $groupName, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('pairNumber: $pairNumber, ')
          ..write('subject: $subject, ')
          ..write('teacher: $teacher, ')
          ..write('room: $room')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _groupNameMeta =
      const VerificationMeta('groupName');
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
      'group_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pairNumberMeta =
      const VerificationMeta('pairNumber');
  @override
  late final GeneratedColumn<int> pairNumber = GeneratedColumn<int>(
      'pair_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, groupName, pairNumber, subject, teacher, room];
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
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('group_name')) {
      context.handle(_groupNameMeta,
          groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta));
    } else if (isInserting) {
      context.missing(_groupNameMeta);
    }
    if (data.containsKey('pair_number')) {
      context.handle(
          _pairNumberMeta,
          pairNumber.isAcceptableOrUnknown(
              data['pair_number']!, _pairNumberMeta));
    } else if (isInserting) {
      context.missing(_pairNumberMeta);
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
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name'])!,
      pairNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pair_number'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      teacher: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}teacher'])!,
      room: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room'])!,
    );
  }

  @override
  $SubstitutionsTable createAlias(String alias) {
    return $SubstitutionsTable(attachedDatabase, alias);
  }
}

class Substitution extends DataClass implements Insertable<Substitution> {
  final int id;
  final DateTime date;
  final String groupName;
  final int pairNumber;
  final String subject;
  final String teacher;
  final String room;
  const Substitution(
      {required this.id,
      required this.date,
      required this.groupName,
      required this.pairNumber,
      required this.subject,
      required this.teacher,
      required this.room});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['group_name'] = Variable<String>(groupName);
    map['pair_number'] = Variable<int>(pairNumber);
    map['subject'] = Variable<String>(subject);
    map['teacher'] = Variable<String>(teacher);
    map['room'] = Variable<String>(room);
    return map;
  }

  SubstitutionsCompanion toCompanion(bool nullToAbsent) {
    return SubstitutionsCompanion(
      id: Value(id),
      date: Value(date),
      groupName: Value(groupName),
      pairNumber: Value(pairNumber),
      subject: Value(subject),
      teacher: Value(teacher),
      room: Value(room),
    );
  }

  factory Substitution.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Substitution(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      groupName: serializer.fromJson<String>(json['groupName']),
      pairNumber: serializer.fromJson<int>(json['pairNumber']),
      subject: serializer.fromJson<String>(json['subject']),
      teacher: serializer.fromJson<String>(json['teacher']),
      room: serializer.fromJson<String>(json['room']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'groupName': serializer.toJson<String>(groupName),
      'pairNumber': serializer.toJson<int>(pairNumber),
      'subject': serializer.toJson<String>(subject),
      'teacher': serializer.toJson<String>(teacher),
      'room': serializer.toJson<String>(room),
    };
  }

  Substitution copyWith(
          {int? id,
          DateTime? date,
          String? groupName,
          int? pairNumber,
          String? subject,
          String? teacher,
          String? room}) =>
      Substitution(
        id: id ?? this.id,
        date: date ?? this.date,
        groupName: groupName ?? this.groupName,
        pairNumber: pairNumber ?? this.pairNumber,
        subject: subject ?? this.subject,
        teacher: teacher ?? this.teacher,
        room: room ?? this.room,
      );
  Substitution copyWithCompanion(SubstitutionsCompanion data) {
    return Substitution(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      pairNumber:
          data.pairNumber.present ? data.pairNumber.value : this.pairNumber,
      subject: data.subject.present ? data.subject.value : this.subject,
      teacher: data.teacher.present ? data.teacher.value : this.teacher,
      room: data.room.present ? data.room.value : this.room,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Substitution(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('groupName: $groupName, ')
          ..write('pairNumber: $pairNumber, ')
          ..write('subject: $subject, ')
          ..write('teacher: $teacher, ')
          ..write('room: $room')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, groupName, pairNumber, subject, teacher, room);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Substitution &&
          other.id == this.id &&
          other.date == this.date &&
          other.groupName == this.groupName &&
          other.pairNumber == this.pairNumber &&
          other.subject == this.subject &&
          other.teacher == this.teacher &&
          other.room == this.room);
}

class SubstitutionsCompanion extends UpdateCompanion<Substitution> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> groupName;
  final Value<int> pairNumber;
  final Value<String> subject;
  final Value<String> teacher;
  final Value<String> room;
  const SubstitutionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.groupName = const Value.absent(),
    this.pairNumber = const Value.absent(),
    this.subject = const Value.absent(),
    this.teacher = const Value.absent(),
    this.room = const Value.absent(),
  });
  SubstitutionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String groupName,
    required int pairNumber,
    required String subject,
    required String teacher,
    required String room,
  })  : date = Value(date),
        groupName = Value(groupName),
        pairNumber = Value(pairNumber),
        subject = Value(subject),
        teacher = Value(teacher),
        room = Value(room);
  static Insertable<Substitution> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? groupName,
    Expression<int>? pairNumber,
    Expression<String>? subject,
    Expression<String>? teacher,
    Expression<String>? room,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (groupName != null) 'group_name': groupName,
      if (pairNumber != null) 'pair_number': pairNumber,
      if (subject != null) 'subject': subject,
      if (teacher != null) 'teacher': teacher,
      if (room != null) 'room': room,
    });
  }

  SubstitutionsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<String>? groupName,
      Value<int>? pairNumber,
      Value<String>? subject,
      Value<String>? teacher,
      Value<String>? room}) {
    return SubstitutionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      groupName: groupName ?? this.groupName,
      pairNumber: pairNumber ?? this.pairNumber,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      room: room ?? this.room,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (pairNumber.present) {
      map['pair_number'] = Variable<int>(pairNumber.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubstitutionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('groupName: $groupName, ')
          ..write('pairNumber: $pairNumber, ')
          ..write('subject: $subject, ')
          ..write('teacher: $teacher, ')
          ..write('room: $room')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BaseSchedulesTable baseSchedules = $BaseSchedulesTable(this);
  late final $SubstitutionsTable substitutions = $SubstitutionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [baseSchedules, substitutions];
}

typedef $$BaseSchedulesTableCreateCompanionBuilder = BaseSchedulesCompanion
    Function({
  Value<int> id,
  required String groupName,
  required int dayOfWeek,
  required int pairNumber,
  required String subject,
  required String teacher,
  required String room,
});
typedef $$BaseSchedulesTableUpdateCompanionBuilder = BaseSchedulesCompanion
    Function({
  Value<int> id,
  Value<String> groupName,
  Value<int> dayOfWeek,
  Value<int> pairNumber,
  Value<String> subject,
  Value<String> teacher,
  Value<String> room,
});

class $$BaseSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $BaseSchedulesTable> {
  $$BaseSchedulesTableFilterComposer({
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

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pairNumber => $composableBuilder(
      column: $table.pairNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teacher => $composableBuilder(
      column: $table.teacher, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnFilters(column));
}

class $$BaseSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $BaseSchedulesTable> {
  $$BaseSchedulesTableOrderingComposer({
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

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pairNumber => $composableBuilder(
      column: $table.pairNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teacher => $composableBuilder(
      column: $table.teacher, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnOrderings(column));
}

class $$BaseSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BaseSchedulesTable> {
  $$BaseSchedulesTableAnnotationComposer({
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

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<int> get pairNumber => $composableBuilder(
      column: $table.pairNumber, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get teacher =>
      $composableBuilder(column: $table.teacher, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);
}

class $$BaseSchedulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BaseSchedulesTable,
    BaseSchedule,
    $$BaseSchedulesTableFilterComposer,
    $$BaseSchedulesTableOrderingComposer,
    $$BaseSchedulesTableAnnotationComposer,
    $$BaseSchedulesTableCreateCompanionBuilder,
    $$BaseSchedulesTableUpdateCompanionBuilder,
    (
      BaseSchedule,
      BaseReferences<_$AppDatabase, $BaseSchedulesTable, BaseSchedule>
    ),
    BaseSchedule,
    PrefetchHooks Function()> {
  $$BaseSchedulesTableTableManager(_$AppDatabase db, $BaseSchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BaseSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BaseSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BaseSchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> groupName = const Value.absent(),
            Value<int> dayOfWeek = const Value.absent(),
            Value<int> pairNumber = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String> teacher = const Value.absent(),
            Value<String> room = const Value.absent(),
          }) =>
              BaseSchedulesCompanion(
            id: id,
            groupName: groupName,
            dayOfWeek: dayOfWeek,
            pairNumber: pairNumber,
            subject: subject,
            teacher: teacher,
            room: room,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String groupName,
            required int dayOfWeek,
            required int pairNumber,
            required String subject,
            required String teacher,
            required String room,
          }) =>
              BaseSchedulesCompanion.insert(
            id: id,
            groupName: groupName,
            dayOfWeek: dayOfWeek,
            pairNumber: pairNumber,
            subject: subject,
            teacher: teacher,
            room: room,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BaseSchedulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BaseSchedulesTable,
    BaseSchedule,
    $$BaseSchedulesTableFilterComposer,
    $$BaseSchedulesTableOrderingComposer,
    $$BaseSchedulesTableAnnotationComposer,
    $$BaseSchedulesTableCreateCompanionBuilder,
    $$BaseSchedulesTableUpdateCompanionBuilder,
    (
      BaseSchedule,
      BaseReferences<_$AppDatabase, $BaseSchedulesTable, BaseSchedule>
    ),
    BaseSchedule,
    PrefetchHooks Function()>;
typedef $$SubstitutionsTableCreateCompanionBuilder = SubstitutionsCompanion
    Function({
  Value<int> id,
  required DateTime date,
  required String groupName,
  required int pairNumber,
  required String subject,
  required String teacher,
  required String room,
});
typedef $$SubstitutionsTableUpdateCompanionBuilder = SubstitutionsCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> groupName,
  Value<int> pairNumber,
  Value<String> subject,
  Value<String> teacher,
  Value<String> room,
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

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pairNumber => $composableBuilder(
      column: $table.pairNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teacher => $composableBuilder(
      column: $table.teacher, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pairNumber => $composableBuilder(
      column: $table.pairNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teacher => $composableBuilder(
      column: $table.teacher, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<int> get pairNumber => $composableBuilder(
      column: $table.pairNumber, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get teacher =>
      $composableBuilder(column: $table.teacher, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);
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
            Value<DateTime> date = const Value.absent(),
            Value<String> groupName = const Value.absent(),
            Value<int> pairNumber = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String> teacher = const Value.absent(),
            Value<String> room = const Value.absent(),
          }) =>
              SubstitutionsCompanion(
            id: id,
            date: date,
            groupName: groupName,
            pairNumber: pairNumber,
            subject: subject,
            teacher: teacher,
            room: room,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required String groupName,
            required int pairNumber,
            required String subject,
            required String teacher,
            required String room,
          }) =>
              SubstitutionsCompanion.insert(
            id: id,
            date: date,
            groupName: groupName,
            pairNumber: pairNumber,
            subject: subject,
            teacher: teacher,
            room: room,
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
  $$BaseSchedulesTableTableManager get baseSchedules =>
      $$BaseSchedulesTableTableManager(_db, _db.baseSchedules);
  $$SubstitutionsTableTableManager get substitutions =>
      $$SubstitutionsTableTableManager(_db, _db.substitutions);
}
