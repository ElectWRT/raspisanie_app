// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LessonsTable extends Lessons with TableInfo<$LessonsTable, Lesson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<WeekType, int> weekType =
      GeneratedColumn<int>('week_type', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<WeekType>($LessonsTable.$converterweekType);
  static const VerificationMeta _subgroupMeta =
      const VerificationMeta('subgroup');
  @override
  late final GeneratedColumn<String> subgroup = GeneratedColumn<String>(
      'subgroup', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
      'room', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        groupName,
        dayOfWeek,
        pairNumber,
        weekType,
        subgroup,
        subject,
        teacher,
        room
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lessons';
  @override
  VerificationContext validateIntegrity(Insertable<Lesson> instance,
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
    if (data.containsKey('subgroup')) {
      context.handle(_subgroupMeta,
          subgroup.isAcceptableOrUnknown(data['subgroup']!, _subgroupMeta));
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
    }
    if (data.containsKey('room')) {
      context.handle(
          _roomMeta, room.isAcceptableOrUnknown(data['room']!, _roomMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lesson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lesson(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name'])!,
      dayOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_week'])!,
      pairNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pair_number'])!,
      weekType: $LessonsTable.$converterweekType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}week_type'])!),
      subgroup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subgroup']),
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      teacher: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}teacher'])!,
      room: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room'])!,
    );
  }

  @override
  $LessonsTable createAlias(String alias) {
    return $LessonsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WeekType, int, int> $converterweekType =
      const EnumIndexConverter<WeekType>(WeekType.values);
}

class Lesson extends DataClass implements Insertable<Lesson> {
  final int id;
  final String groupName;

  /// 1 = понедельник ... 7 = воскресенье (как в [DateTime.weekday]).
  final int dayOfWeek;
  final int pairNumber;
  final WeekType weekType;

  /// Номер подгруппы ("1", "2"). null — пара для всей группы.
  final String? subgroup;
  final String subject;
  final String teacher;
  final String room;
  const Lesson(
      {required this.id,
      required this.groupName,
      required this.dayOfWeek,
      required this.pairNumber,
      required this.weekType,
      this.subgroup,
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
    {
      map['week_type'] =
          Variable<int>($LessonsTable.$converterweekType.toSql(weekType));
    }
    if (!nullToAbsent || subgroup != null) {
      map['subgroup'] = Variable<String>(subgroup);
    }
    map['subject'] = Variable<String>(subject);
    map['teacher'] = Variable<String>(teacher);
    map['room'] = Variable<String>(room);
    return map;
  }

  LessonsCompanion toCompanion(bool nullToAbsent) {
    return LessonsCompanion(
      id: Value(id),
      groupName: Value(groupName),
      dayOfWeek: Value(dayOfWeek),
      pairNumber: Value(pairNumber),
      weekType: Value(weekType),
      subgroup: subgroup == null && nullToAbsent
          ? const Value.absent()
          : Value(subgroup),
      subject: Value(subject),
      teacher: Value(teacher),
      room: Value(room),
    );
  }

  factory Lesson.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lesson(
      id: serializer.fromJson<int>(json['id']),
      groupName: serializer.fromJson<String>(json['groupName']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      pairNumber: serializer.fromJson<int>(json['pairNumber']),
      weekType: $LessonsTable.$converterweekType
          .fromJson(serializer.fromJson<int>(json['weekType'])),
      subgroup: serializer.fromJson<String?>(json['subgroup']),
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
      'weekType': serializer
          .toJson<int>($LessonsTable.$converterweekType.toJson(weekType)),
      'subgroup': serializer.toJson<String?>(subgroup),
      'subject': serializer.toJson<String>(subject),
      'teacher': serializer.toJson<String>(teacher),
      'room': serializer.toJson<String>(room),
    };
  }

  Lesson copyWith(
          {int? id,
          String? groupName,
          int? dayOfWeek,
          int? pairNumber,
          WeekType? weekType,
          Value<String?> subgroup = const Value.absent(),
          String? subject,
          String? teacher,
          String? room}) =>
      Lesson(
        id: id ?? this.id,
        groupName: groupName ?? this.groupName,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        pairNumber: pairNumber ?? this.pairNumber,
        weekType: weekType ?? this.weekType,
        subgroup: subgroup.present ? subgroup.value : this.subgroup,
        subject: subject ?? this.subject,
        teacher: teacher ?? this.teacher,
        room: room ?? this.room,
      );
  Lesson copyWithCompanion(LessonsCompanion data) {
    return Lesson(
      id: data.id.present ? data.id.value : this.id,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      pairNumber:
          data.pairNumber.present ? data.pairNumber.value : this.pairNumber,
      weekType: data.weekType.present ? data.weekType.value : this.weekType,
      subgroup: data.subgroup.present ? data.subgroup.value : this.subgroup,
      subject: data.subject.present ? data.subject.value : this.subject,
      teacher: data.teacher.present ? data.teacher.value : this.teacher,
      room: data.room.present ? data.room.value : this.room,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lesson(')
          ..write('id: $id, ')
          ..write('groupName: $groupName, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('pairNumber: $pairNumber, ')
          ..write('weekType: $weekType, ')
          ..write('subgroup: $subgroup, ')
          ..write('subject: $subject, ')
          ..write('teacher: $teacher, ')
          ..write('room: $room')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupName, dayOfWeek, pairNumber,
      weekType, subgroup, subject, teacher, room);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lesson &&
          other.id == this.id &&
          other.groupName == this.groupName &&
          other.dayOfWeek == this.dayOfWeek &&
          other.pairNumber == this.pairNumber &&
          other.weekType == this.weekType &&
          other.subgroup == this.subgroup &&
          other.subject == this.subject &&
          other.teacher == this.teacher &&
          other.room == this.room);
}

class LessonsCompanion extends UpdateCompanion<Lesson> {
  final Value<int> id;
  final Value<String> groupName;
  final Value<int> dayOfWeek;
  final Value<int> pairNumber;
  final Value<WeekType> weekType;
  final Value<String?> subgroup;
  final Value<String> subject;
  final Value<String> teacher;
  final Value<String> room;
  const LessonsCompanion({
    this.id = const Value.absent(),
    this.groupName = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.pairNumber = const Value.absent(),
    this.weekType = const Value.absent(),
    this.subgroup = const Value.absent(),
    this.subject = const Value.absent(),
    this.teacher = const Value.absent(),
    this.room = const Value.absent(),
  });
  LessonsCompanion.insert({
    this.id = const Value.absent(),
    required String groupName,
    required int dayOfWeek,
    required int pairNumber,
    this.weekType = const Value.absent(),
    this.subgroup = const Value.absent(),
    required String subject,
    this.teacher = const Value.absent(),
    this.room = const Value.absent(),
  })  : groupName = Value(groupName),
        dayOfWeek = Value(dayOfWeek),
        pairNumber = Value(pairNumber),
        subject = Value(subject);
  static Insertable<Lesson> custom({
    Expression<int>? id,
    Expression<String>? groupName,
    Expression<int>? dayOfWeek,
    Expression<int>? pairNumber,
    Expression<int>? weekType,
    Expression<String>? subgroup,
    Expression<String>? subject,
    Expression<String>? teacher,
    Expression<String>? room,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupName != null) 'group_name': groupName,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (pairNumber != null) 'pair_number': pairNumber,
      if (weekType != null) 'week_type': weekType,
      if (subgroup != null) 'subgroup': subgroup,
      if (subject != null) 'subject': subject,
      if (teacher != null) 'teacher': teacher,
      if (room != null) 'room': room,
    });
  }

  LessonsCompanion copyWith(
      {Value<int>? id,
      Value<String>? groupName,
      Value<int>? dayOfWeek,
      Value<int>? pairNumber,
      Value<WeekType>? weekType,
      Value<String?>? subgroup,
      Value<String>? subject,
      Value<String>? teacher,
      Value<String>? room}) {
    return LessonsCompanion(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      pairNumber: pairNumber ?? this.pairNumber,
      weekType: weekType ?? this.weekType,
      subgroup: subgroup ?? this.subgroup,
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
    if (weekType.present) {
      map['week_type'] =
          Variable<int>($LessonsTable.$converterweekType.toSql(weekType.value));
    }
    if (subgroup.present) {
      map['subgroup'] = Variable<String>(subgroup.value);
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
    return (StringBuffer('LessonsCompanion(')
          ..write('id: $id, ')
          ..write('groupName: $groupName, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('pairNumber: $pairNumber, ')
          ..write('weekType: $weekType, ')
          ..write('subgroup: $subgroup, ')
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
  static const VerificationMeta _subgroupMeta =
      const VerificationMeta('subgroup');
  @override
  late final GeneratedColumn<String> subgroup = GeneratedColumn<String>(
      'subgroup', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _teacherMeta =
      const VerificationMeta('teacher');
  @override
  late final GeneratedColumn<String> teacher = GeneratedColumn<String>(
      'teacher', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
      'room', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _isCancelledMeta =
      const VerificationMeta('isCancelled');
  @override
  late final GeneratedColumn<bool> isCancelled = GeneratedColumn<bool>(
      'is_cancelled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_cancelled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        groupName,
        pairNumber,
        subgroup,
        subject,
        teacher,
        room,
        isCancelled,
        note
      ];
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
    if (data.containsKey('subgroup')) {
      context.handle(_subgroupMeta,
          subgroup.isAcceptableOrUnknown(data['subgroup']!, _subgroupMeta));
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    }
    if (data.containsKey('teacher')) {
      context.handle(_teacherMeta,
          teacher.isAcceptableOrUnknown(data['teacher']!, _teacherMeta));
    }
    if (data.containsKey('room')) {
      context.handle(
          _roomMeta, room.isAcceptableOrUnknown(data['room']!, _roomMeta));
    }
    if (data.containsKey('is_cancelled')) {
      context.handle(
          _isCancelledMeta,
          isCancelled.isAcceptableOrUnknown(
              data['is_cancelled']!, _isCancelledMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {date, groupName, pairNumber, subgroup},
      ];
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
      subgroup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subgroup']),
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      teacher: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}teacher'])!,
      room: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room'])!,
      isCancelled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_cancelled'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $SubstitutionsTable createAlias(String alias) {
    return $SubstitutionsTable(attachedDatabase, alias);
  }
}

class Substitution extends DataClass implements Insertable<Substitution> {
  final int id;

  /// Всегда полночь локального времени — ключ дня.
  final DateTime date;
  final String groupName;
  final int pairNumber;
  final String? subgroup;
  final String subject;
  final String teacher;
  final String room;

  /// true — пара снята («группа гуляет»), предмет показывать не нужно.
  final bool isCancelled;

  /// Произвольная приписка из документа («самостоятельно», «дист.» и т.п.).
  final String? note;
  const Substitution(
      {required this.id,
      required this.date,
      required this.groupName,
      required this.pairNumber,
      this.subgroup,
      required this.subject,
      required this.teacher,
      required this.room,
      required this.isCancelled,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['group_name'] = Variable<String>(groupName);
    map['pair_number'] = Variable<int>(pairNumber);
    if (!nullToAbsent || subgroup != null) {
      map['subgroup'] = Variable<String>(subgroup);
    }
    map['subject'] = Variable<String>(subject);
    map['teacher'] = Variable<String>(teacher);
    map['room'] = Variable<String>(room);
    map['is_cancelled'] = Variable<bool>(isCancelled);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  SubstitutionsCompanion toCompanion(bool nullToAbsent) {
    return SubstitutionsCompanion(
      id: Value(id),
      date: Value(date),
      groupName: Value(groupName),
      pairNumber: Value(pairNumber),
      subgroup: subgroup == null && nullToAbsent
          ? const Value.absent()
          : Value(subgroup),
      subject: Value(subject),
      teacher: Value(teacher),
      room: Value(room),
      isCancelled: Value(isCancelled),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
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
      subgroup: serializer.fromJson<String?>(json['subgroup']),
      subject: serializer.fromJson<String>(json['subject']),
      teacher: serializer.fromJson<String>(json['teacher']),
      room: serializer.fromJson<String>(json['room']),
      isCancelled: serializer.fromJson<bool>(json['isCancelled']),
      note: serializer.fromJson<String?>(json['note']),
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
      'subgroup': serializer.toJson<String?>(subgroup),
      'subject': serializer.toJson<String>(subject),
      'teacher': serializer.toJson<String>(teacher),
      'room': serializer.toJson<String>(room),
      'isCancelled': serializer.toJson<bool>(isCancelled),
      'note': serializer.toJson<String?>(note),
    };
  }

  Substitution copyWith(
          {int? id,
          DateTime? date,
          String? groupName,
          int? pairNumber,
          Value<String?> subgroup = const Value.absent(),
          String? subject,
          String? teacher,
          String? room,
          bool? isCancelled,
          Value<String?> note = const Value.absent()}) =>
      Substitution(
        id: id ?? this.id,
        date: date ?? this.date,
        groupName: groupName ?? this.groupName,
        pairNumber: pairNumber ?? this.pairNumber,
        subgroup: subgroup.present ? subgroup.value : this.subgroup,
        subject: subject ?? this.subject,
        teacher: teacher ?? this.teacher,
        room: room ?? this.room,
        isCancelled: isCancelled ?? this.isCancelled,
        note: note.present ? note.value : this.note,
      );
  Substitution copyWithCompanion(SubstitutionsCompanion data) {
    return Substitution(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      pairNumber:
          data.pairNumber.present ? data.pairNumber.value : this.pairNumber,
      subgroup: data.subgroup.present ? data.subgroup.value : this.subgroup,
      subject: data.subject.present ? data.subject.value : this.subject,
      teacher: data.teacher.present ? data.teacher.value : this.teacher,
      room: data.room.present ? data.room.value : this.room,
      isCancelled:
          data.isCancelled.present ? data.isCancelled.value : this.isCancelled,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Substitution(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('groupName: $groupName, ')
          ..write('pairNumber: $pairNumber, ')
          ..write('subgroup: $subgroup, ')
          ..write('subject: $subject, ')
          ..write('teacher: $teacher, ')
          ..write('room: $room, ')
          ..write('isCancelled: $isCancelled, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, groupName, pairNumber, subgroup,
      subject, teacher, room, isCancelled, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Substitution &&
          other.id == this.id &&
          other.date == this.date &&
          other.groupName == this.groupName &&
          other.pairNumber == this.pairNumber &&
          other.subgroup == this.subgroup &&
          other.subject == this.subject &&
          other.teacher == this.teacher &&
          other.room == this.room &&
          other.isCancelled == this.isCancelled &&
          other.note == this.note);
}

class SubstitutionsCompanion extends UpdateCompanion<Substitution> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> groupName;
  final Value<int> pairNumber;
  final Value<String?> subgroup;
  final Value<String> subject;
  final Value<String> teacher;
  final Value<String> room;
  final Value<bool> isCancelled;
  final Value<String?> note;
  const SubstitutionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.groupName = const Value.absent(),
    this.pairNumber = const Value.absent(),
    this.subgroup = const Value.absent(),
    this.subject = const Value.absent(),
    this.teacher = const Value.absent(),
    this.room = const Value.absent(),
    this.isCancelled = const Value.absent(),
    this.note = const Value.absent(),
  });
  SubstitutionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String groupName,
    required int pairNumber,
    this.subgroup = const Value.absent(),
    this.subject = const Value.absent(),
    this.teacher = const Value.absent(),
    this.room = const Value.absent(),
    this.isCancelled = const Value.absent(),
    this.note = const Value.absent(),
  })  : date = Value(date),
        groupName = Value(groupName),
        pairNumber = Value(pairNumber);
  static Insertable<Substitution> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? groupName,
    Expression<int>? pairNumber,
    Expression<String>? subgroup,
    Expression<String>? subject,
    Expression<String>? teacher,
    Expression<String>? room,
    Expression<bool>? isCancelled,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (groupName != null) 'group_name': groupName,
      if (pairNumber != null) 'pair_number': pairNumber,
      if (subgroup != null) 'subgroup': subgroup,
      if (subject != null) 'subject': subject,
      if (teacher != null) 'teacher': teacher,
      if (room != null) 'room': room,
      if (isCancelled != null) 'is_cancelled': isCancelled,
      if (note != null) 'note': note,
    });
  }

  SubstitutionsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<String>? groupName,
      Value<int>? pairNumber,
      Value<String?>? subgroup,
      Value<String>? subject,
      Value<String>? teacher,
      Value<String>? room,
      Value<bool>? isCancelled,
      Value<String?>? note}) {
    return SubstitutionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      groupName: groupName ?? this.groupName,
      pairNumber: pairNumber ?? this.pairNumber,
      subgroup: subgroup ?? this.subgroup,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      room: room ?? this.room,
      isCancelled: isCancelled ?? this.isCancelled,
      note: note ?? this.note,
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
    if (subgroup.present) {
      map['subgroup'] = Variable<String>(subgroup.value);
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
    if (isCancelled.present) {
      map['is_cancelled'] = Variable<bool>(isCancelled.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
          ..write('subgroup: $subgroup, ')
          ..write('subject: $subject, ')
          ..write('teacher: $teacher, ')
          ..write('room: $room, ')
          ..write('isCancelled: $isCancelled, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(Insertable<AppMetaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String key;
  final String value;
  const AppMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppMetaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaData copyWith({String? key, String? value}) => AppMetaData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LessonsTable lessons = $LessonsTable(this);
  late final $SubstitutionsTable substitutions = $SubstitutionsTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [lessons, substitutions, appMeta];
}

typedef $$LessonsTableCreateCompanionBuilder = LessonsCompanion Function({
  Value<int> id,
  required String groupName,
  required int dayOfWeek,
  required int pairNumber,
  Value<WeekType> weekType,
  Value<String?> subgroup,
  required String subject,
  Value<String> teacher,
  Value<String> room,
});
typedef $$LessonsTableUpdateCompanionBuilder = LessonsCompanion Function({
  Value<int> id,
  Value<String> groupName,
  Value<int> dayOfWeek,
  Value<int> pairNumber,
  Value<WeekType> weekType,
  Value<String?> subgroup,
  Value<String> subject,
  Value<String> teacher,
  Value<String> room,
});

class $$LessonsTableFilterComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<WeekType, WeekType, int> get weekType =>
      $composableBuilder(
          column: $table.weekType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get subgroup => $composableBuilder(
      column: $table.subgroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teacher => $composableBuilder(
      column: $table.teacher, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnFilters(column));
}

class $$LessonsTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableOrderingComposer({
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

  ColumnOrderings<int> get weekType => $composableBuilder(
      column: $table.weekType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subgroup => $composableBuilder(
      column: $table.subgroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teacher => $composableBuilder(
      column: $table.teacher, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnOrderings(column));
}

class $$LessonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<WeekType, int> get weekType =>
      $composableBuilder(column: $table.weekType, builder: (column) => column);

  GeneratedColumn<String> get subgroup =>
      $composableBuilder(column: $table.subgroup, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get teacher =>
      $composableBuilder(column: $table.teacher, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);
}

class $$LessonsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LessonsTable,
    Lesson,
    $$LessonsTableFilterComposer,
    $$LessonsTableOrderingComposer,
    $$LessonsTableAnnotationComposer,
    $$LessonsTableCreateCompanionBuilder,
    $$LessonsTableUpdateCompanionBuilder,
    (Lesson, BaseReferences<_$AppDatabase, $LessonsTable, Lesson>),
    Lesson,
    PrefetchHooks Function()> {
  $$LessonsTableTableManager(_$AppDatabase db, $LessonsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> groupName = const Value.absent(),
            Value<int> dayOfWeek = const Value.absent(),
            Value<int> pairNumber = const Value.absent(),
            Value<WeekType> weekType = const Value.absent(),
            Value<String?> subgroup = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String> teacher = const Value.absent(),
            Value<String> room = const Value.absent(),
          }) =>
              LessonsCompanion(
            id: id,
            groupName: groupName,
            dayOfWeek: dayOfWeek,
            pairNumber: pairNumber,
            weekType: weekType,
            subgroup: subgroup,
            subject: subject,
            teacher: teacher,
            room: room,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String groupName,
            required int dayOfWeek,
            required int pairNumber,
            Value<WeekType> weekType = const Value.absent(),
            Value<String?> subgroup = const Value.absent(),
            required String subject,
            Value<String> teacher = const Value.absent(),
            Value<String> room = const Value.absent(),
          }) =>
              LessonsCompanion.insert(
            id: id,
            groupName: groupName,
            dayOfWeek: dayOfWeek,
            pairNumber: pairNumber,
            weekType: weekType,
            subgroup: subgroup,
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

typedef $$LessonsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LessonsTable,
    Lesson,
    $$LessonsTableFilterComposer,
    $$LessonsTableOrderingComposer,
    $$LessonsTableAnnotationComposer,
    $$LessonsTableCreateCompanionBuilder,
    $$LessonsTableUpdateCompanionBuilder,
    (Lesson, BaseReferences<_$AppDatabase, $LessonsTable, Lesson>),
    Lesson,
    PrefetchHooks Function()>;
typedef $$SubstitutionsTableCreateCompanionBuilder = SubstitutionsCompanion
    Function({
  Value<int> id,
  required DateTime date,
  required String groupName,
  required int pairNumber,
  Value<String?> subgroup,
  Value<String> subject,
  Value<String> teacher,
  Value<String> room,
  Value<bool> isCancelled,
  Value<String?> note,
});
typedef $$SubstitutionsTableUpdateCompanionBuilder = SubstitutionsCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> groupName,
  Value<int> pairNumber,
  Value<String?> subgroup,
  Value<String> subject,
  Value<String> teacher,
  Value<String> room,
  Value<bool> isCancelled,
  Value<String?> note,
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

  ColumnFilters<String> get subgroup => $composableBuilder(
      column: $table.subgroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teacher => $composableBuilder(
      column: $table.teacher, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCancelled => $composableBuilder(
      column: $table.isCancelled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get subgroup => $composableBuilder(
      column: $table.subgroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teacher => $composableBuilder(
      column: $table.teacher, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCancelled => $composableBuilder(
      column: $table.isCancelled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get subgroup =>
      $composableBuilder(column: $table.subgroup, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get teacher =>
      $composableBuilder(column: $table.teacher, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  GeneratedColumn<bool> get isCancelled => $composableBuilder(
      column: $table.isCancelled, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
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
            Value<String?> subgroup = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String> teacher = const Value.absent(),
            Value<String> room = const Value.absent(),
            Value<bool> isCancelled = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              SubstitutionsCompanion(
            id: id,
            date: date,
            groupName: groupName,
            pairNumber: pairNumber,
            subgroup: subgroup,
            subject: subject,
            teacher: teacher,
            room: room,
            isCancelled: isCancelled,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required String groupName,
            required int pairNumber,
            Value<String?> subgroup = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String> teacher = const Value.absent(),
            Value<String> room = const Value.absent(),
            Value<bool> isCancelled = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              SubstitutionsCompanion.insert(
            id: id,
            date: date,
            groupName: groupName,
            pairNumber: pairNumber,
            subgroup: subgroup,
            subject: subject,
            teacher: teacher,
            room: room,
            isCancelled: isCancelled,
            note: note,
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
typedef $$AppMetaTableCreateCompanionBuilder = AppMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppMetaTableUpdateCompanionBuilder = AppMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppMetaTable,
    AppMetaData,
    $$AppMetaTableFilterComposer,
    $$AppMetaTableOrderingComposer,
    $$AppMetaTableAnnotationComposer,
    $$AppMetaTableCreateCompanionBuilder,
    $$AppMetaTableUpdateCompanionBuilder,
    (AppMetaData, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>),
    AppMetaData,
    PrefetchHooks Function()> {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetaCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetaCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppMetaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppMetaTable,
    AppMetaData,
    $$AppMetaTableFilterComposer,
    $$AppMetaTableOrderingComposer,
    $$AppMetaTableAnnotationComposer,
    $$AppMetaTableCreateCompanionBuilder,
    $$AppMetaTableUpdateCompanionBuilder,
    (AppMetaData, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>),
    AppMetaData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LessonsTableTableManager get lessons =>
      $$LessonsTableTableManager(_db, _db.lessons);
  $$SubstitutionsTableTableManager get substitutions =>
      $$SubstitutionsTableTableManager(_db, _db.substitutions);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
}
