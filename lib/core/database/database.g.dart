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

class $HomeworksTable extends Homeworks
    with TableInfo<$HomeworksTable, Homework> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HomeworksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<HomeworkPriority, int> priority =
      GeneratedColumn<int>('priority', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(1))
          .withConverter<HomeworkPriority>($HomeworksTable.$converterpriority);
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
      'is_done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        groupName,
        subject,
        description,
        dueDate,
        priority,
        isDone,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'homeworks';
  @override
  VerificationContext validateIntegrity(Insertable<Homework> instance,
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
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('is_done')) {
      context.handle(_isDoneMeta,
          isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta));
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
  Homework map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Homework(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      priority: $HomeworksTable.$converterpriority.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!),
      isDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_done'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $HomeworksTable createAlias(String alias) {
    return $HomeworksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HomeworkPriority, int, int> $converterpriority =
      const EnumIndexConverter<HomeworkPriority>(HomeworkPriority.values);
}

class Homework extends DataClass implements Insertable<Homework> {
  final int id;
  final String groupName;
  final String subject;

  /// Что задали.
  final String description;

  /// День сдачи — всегда полночь.
  final DateTime dueDate;
  final HomeworkPriority priority;
  final bool isDone;
  final DateTime createdAt;
  const Homework(
      {required this.id,
      required this.groupName,
      required this.subject,
      required this.description,
      required this.dueDate,
      required this.priority,
      required this.isDone,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_name'] = Variable<String>(groupName);
    map['subject'] = Variable<String>(subject);
    map['description'] = Variable<String>(description);
    map['due_date'] = Variable<DateTime>(dueDate);
    {
      map['priority'] =
          Variable<int>($HomeworksTable.$converterpriority.toSql(priority));
    }
    map['is_done'] = Variable<bool>(isDone);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HomeworksCompanion toCompanion(bool nullToAbsent) {
    return HomeworksCompanion(
      id: Value(id),
      groupName: Value(groupName),
      subject: Value(subject),
      description: Value(description),
      dueDate: Value(dueDate),
      priority: Value(priority),
      isDone: Value(isDone),
      createdAt: Value(createdAt),
    );
  }

  factory Homework.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Homework(
      id: serializer.fromJson<int>(json['id']),
      groupName: serializer.fromJson<String>(json['groupName']),
      subject: serializer.fromJson<String>(json['subject']),
      description: serializer.fromJson<String>(json['description']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      priority: $HomeworksTable.$converterpriority
          .fromJson(serializer.fromJson<int>(json['priority'])),
      isDone: serializer.fromJson<bool>(json['isDone']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupName': serializer.toJson<String>(groupName),
      'subject': serializer.toJson<String>(subject),
      'description': serializer.toJson<String>(description),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'priority': serializer
          .toJson<int>($HomeworksTable.$converterpriority.toJson(priority)),
      'isDone': serializer.toJson<bool>(isDone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Homework copyWith(
          {int? id,
          String? groupName,
          String? subject,
          String? description,
          DateTime? dueDate,
          HomeworkPriority? priority,
          bool? isDone,
          DateTime? createdAt}) =>
      Homework(
        id: id ?? this.id,
        groupName: groupName ?? this.groupName,
        subject: subject ?? this.subject,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
        priority: priority ?? this.priority,
        isDone: isDone ?? this.isDone,
        createdAt: createdAt ?? this.createdAt,
      );
  Homework copyWithCompanion(HomeworksCompanion data) {
    return Homework(
      id: data.id.present ? data.id.value : this.id,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      subject: data.subject.present ? data.subject.value : this.subject,
      description:
          data.description.present ? data.description.value : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      priority: data.priority.present ? data.priority.value : this.priority,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Homework(')
          ..write('id: $id, ')
          ..write('groupName: $groupName, ')
          ..write('subject: $subject, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('priority: $priority, ')
          ..write('isDone: $isDone, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupName, subject, description, dueDate,
      priority, isDone, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Homework &&
          other.id == this.id &&
          other.groupName == this.groupName &&
          other.subject == this.subject &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.priority == this.priority &&
          other.isDone == this.isDone &&
          other.createdAt == this.createdAt);
}

class HomeworksCompanion extends UpdateCompanion<Homework> {
  final Value<int> id;
  final Value<String> groupName;
  final Value<String> subject;
  final Value<String> description;
  final Value<DateTime> dueDate;
  final Value<HomeworkPriority> priority;
  final Value<bool> isDone;
  final Value<DateTime> createdAt;
  const HomeworksCompanion({
    this.id = const Value.absent(),
    this.groupName = const Value.absent(),
    this.subject = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.priority = const Value.absent(),
    this.isDone = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HomeworksCompanion.insert({
    this.id = const Value.absent(),
    required String groupName,
    required String subject,
    required String description,
    required DateTime dueDate,
    this.priority = const Value.absent(),
    this.isDone = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : groupName = Value(groupName),
        subject = Value(subject),
        description = Value(description),
        dueDate = Value(dueDate);
  static Insertable<Homework> custom({
    Expression<int>? id,
    Expression<String>? groupName,
    Expression<String>? subject,
    Expression<String>? description,
    Expression<DateTime>? dueDate,
    Expression<int>? priority,
    Expression<bool>? isDone,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupName != null) 'group_name': groupName,
      if (subject != null) 'subject': subject,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (priority != null) 'priority': priority,
      if (isDone != null) 'is_done': isDone,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HomeworksCompanion copyWith(
      {Value<int>? id,
      Value<String>? groupName,
      Value<String>? subject,
      Value<String>? description,
      Value<DateTime>? dueDate,
      Value<HomeworkPriority>? priority,
      Value<bool>? isDone,
      Value<DateTime>? createdAt}) {
    return HomeworksCompanion(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
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
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(
          $HomeworksTable.$converterpriority.toSql(priority.value));
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HomeworksCompanion(')
          ..write('id: $id, ')
          ..write('groupName: $groupName, ')
          ..write('subject: $subject, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('priority: $priority, ')
          ..write('isDone: $isDone, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AttendancesTable extends Attendances
    with TableInfo<$AttendancesTable, Attendance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendancesTable(this.attachedDatabase, [this._alias]);
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
      'subgroup', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<AttendanceStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<AttendanceStatus>($AttendancesTable.$converterstatus);
  static const VerificationMeta _markedAtMeta =
      const VerificationMeta('markedAt');
  @override
  late final GeneratedColumn<DateTime> markedAt = GeneratedColumn<DateTime>(
      'marked_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, groupName, pairNumber, subgroup, subject, status, markedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendances';
  @override
  VerificationContext validateIntegrity(Insertable<Attendance> instance,
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
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('marked_at')) {
      context.handle(_markedAtMeta,
          markedAt.isAcceptableOrUnknown(data['marked_at']!, _markedAtMeta));
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
  Attendance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attendance(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name'])!,
      pairNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pair_number'])!,
      subgroup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subgroup'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      status: $AttendancesTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      markedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}marked_at'])!,
    );
  }

  @override
  $AttendancesTable createAlias(String alias) {
    return $AttendancesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AttendanceStatus, int, int> $converterstatus =
      const EnumIndexConverter<AttendanceStatus>(AttendanceStatus.values);
}

class Attendance extends DataClass implements Insertable<Attendance> {
  final int id;

  /// Всегда полночь локального времени — ключ дня.
  final DateTime date;
  final String groupName;
  final int pairNumber;

  /// Подгруппа: «1», «2» или пустая строка для пары всей группы.
  ///
  /// Пустая строка, а не NULL: колонка входит в уникальный ключ, а SQLite
  /// считает любые два NULL разными значениями — с nullable-колонкой
  /// повторная отметка пары без подгруппы не находила бы конфликт
  /// и создавала вторую строку вместо перезаписи первой.
  final String subgroup;

  /// Предмет на момент отметки — уже с учётом замены, если она была.
  final String subject;
  final AttendanceStatus status;
  final DateTime markedAt;
  const Attendance(
      {required this.id,
      required this.date,
      required this.groupName,
      required this.pairNumber,
      required this.subgroup,
      required this.subject,
      required this.status,
      required this.markedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['group_name'] = Variable<String>(groupName);
    map['pair_number'] = Variable<int>(pairNumber);
    map['subgroup'] = Variable<String>(subgroup);
    map['subject'] = Variable<String>(subject);
    {
      map['status'] =
          Variable<int>($AttendancesTable.$converterstatus.toSql(status));
    }
    map['marked_at'] = Variable<DateTime>(markedAt);
    return map;
  }

  AttendancesCompanion toCompanion(bool nullToAbsent) {
    return AttendancesCompanion(
      id: Value(id),
      date: Value(date),
      groupName: Value(groupName),
      pairNumber: Value(pairNumber),
      subgroup: Value(subgroup),
      subject: Value(subject),
      status: Value(status),
      markedAt: Value(markedAt),
    );
  }

  factory Attendance.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attendance(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      groupName: serializer.fromJson<String>(json['groupName']),
      pairNumber: serializer.fromJson<int>(json['pairNumber']),
      subgroup: serializer.fromJson<String>(json['subgroup']),
      subject: serializer.fromJson<String>(json['subject']),
      status: $AttendancesTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
      markedAt: serializer.fromJson<DateTime>(json['markedAt']),
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
      'subgroup': serializer.toJson<String>(subgroup),
      'subject': serializer.toJson<String>(subject),
      'status': serializer
          .toJson<int>($AttendancesTable.$converterstatus.toJson(status)),
      'markedAt': serializer.toJson<DateTime>(markedAt),
    };
  }

  Attendance copyWith(
          {int? id,
          DateTime? date,
          String? groupName,
          int? pairNumber,
          String? subgroup,
          String? subject,
          AttendanceStatus? status,
          DateTime? markedAt}) =>
      Attendance(
        id: id ?? this.id,
        date: date ?? this.date,
        groupName: groupName ?? this.groupName,
        pairNumber: pairNumber ?? this.pairNumber,
        subgroup: subgroup ?? this.subgroup,
        subject: subject ?? this.subject,
        status: status ?? this.status,
        markedAt: markedAt ?? this.markedAt,
      );
  Attendance copyWithCompanion(AttendancesCompanion data) {
    return Attendance(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      pairNumber:
          data.pairNumber.present ? data.pairNumber.value : this.pairNumber,
      subgroup: data.subgroup.present ? data.subgroup.value : this.subgroup,
      subject: data.subject.present ? data.subject.value : this.subject,
      status: data.status.present ? data.status.value : this.status,
      markedAt: data.markedAt.present ? data.markedAt.value : this.markedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attendance(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('groupName: $groupName, ')
          ..write('pairNumber: $pairNumber, ')
          ..write('subgroup: $subgroup, ')
          ..write('subject: $subject, ')
          ..write('status: $status, ')
          ..write('markedAt: $markedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, date, groupName, pairNumber, subgroup, subject, status, markedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attendance &&
          other.id == this.id &&
          other.date == this.date &&
          other.groupName == this.groupName &&
          other.pairNumber == this.pairNumber &&
          other.subgroup == this.subgroup &&
          other.subject == this.subject &&
          other.status == this.status &&
          other.markedAt == this.markedAt);
}

class AttendancesCompanion extends UpdateCompanion<Attendance> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> groupName;
  final Value<int> pairNumber;
  final Value<String> subgroup;
  final Value<String> subject;
  final Value<AttendanceStatus> status;
  final Value<DateTime> markedAt;
  const AttendancesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.groupName = const Value.absent(),
    this.pairNumber = const Value.absent(),
    this.subgroup = const Value.absent(),
    this.subject = const Value.absent(),
    this.status = const Value.absent(),
    this.markedAt = const Value.absent(),
  });
  AttendancesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String groupName,
    required int pairNumber,
    this.subgroup = const Value.absent(),
    required String subject,
    required AttendanceStatus status,
    this.markedAt = const Value.absent(),
  })  : date = Value(date),
        groupName = Value(groupName),
        pairNumber = Value(pairNumber),
        subject = Value(subject),
        status = Value(status);
  static Insertable<Attendance> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? groupName,
    Expression<int>? pairNumber,
    Expression<String>? subgroup,
    Expression<String>? subject,
    Expression<int>? status,
    Expression<DateTime>? markedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (groupName != null) 'group_name': groupName,
      if (pairNumber != null) 'pair_number': pairNumber,
      if (subgroup != null) 'subgroup': subgroup,
      if (subject != null) 'subject': subject,
      if (status != null) 'status': status,
      if (markedAt != null) 'marked_at': markedAt,
    });
  }

  AttendancesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<String>? groupName,
      Value<int>? pairNumber,
      Value<String>? subgroup,
      Value<String>? subject,
      Value<AttendanceStatus>? status,
      Value<DateTime>? markedAt}) {
    return AttendancesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      groupName: groupName ?? this.groupName,
      pairNumber: pairNumber ?? this.pairNumber,
      subgroup: subgroup ?? this.subgroup,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      markedAt: markedAt ?? this.markedAt,
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
    if (status.present) {
      map['status'] =
          Variable<int>($AttendancesTable.$converterstatus.toSql(status.value));
    }
    if (markedAt.present) {
      map['marked_at'] = Variable<DateTime>(markedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendancesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('groupName: $groupName, ')
          ..write('pairNumber: $pairNumber, ')
          ..write('subgroup: $subgroup, ')
          ..write('subject: $subject, ')
          ..write('status: $status, ')
          ..write('markedAt: $markedAt')
          ..write(')'))
        .toString();
  }
}

class $SubjectProfilesTable extends SubjectProfiles
    with TableInfo<$SubjectProfilesTable, SubjectProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _subjectKeyMeta =
      const VerificationMeta('subjectKey');
  @override
  late final GeneratedColumn<String> subjectKey = GeneratedColumn<String>(
      'subject_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isMajorMeta =
      const VerificationMeta('isMajor');
  @override
  late final GeneratedColumn<bool> isMajor = GeneratedColumn<bool>(
      'is_major', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_major" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _itemsMeta = const VerificationMeta('items');
  @override
  late final GeneratedColumn<String> items = GeneratedColumn<String>(
      'items', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, groupName, subjectKey, subject, isMajor, items, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subject_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<SubjectProfile> instance,
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
    if (data.containsKey('subject_key')) {
      context.handle(
          _subjectKeyMeta,
          subjectKey.isAcceptableOrUnknown(
              data['subject_key']!, _subjectKeyMeta));
    } else if (isInserting) {
      context.missing(_subjectKeyMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('is_major')) {
      context.handle(_isMajorMeta,
          isMajor.isAcceptableOrUnknown(data['is_major']!, _isMajorMeta));
    }
    if (data.containsKey('items')) {
      context.handle(
          _itemsMeta, items.isAcceptableOrUnknown(data['items']!, _itemsMeta));
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
        {groupName, subjectKey},
      ];
  @override
  SubjectProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubjectProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name'])!,
      subjectKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_key'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      isMajor: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_major'])!,
      items: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}items'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $SubjectProfilesTable createAlias(String alias) {
    return $SubjectProfilesTable(attachedDatabase, alias);
  }
}

class SubjectProfile extends DataClass implements Insertable<SubjectProfile> {
  final int id;
  final String groupName;

  /// Название в нижнем регистре — в расписании и заменах предмет пишут
  /// по-разному, а профиль должен находиться в обоих случаях.
  final String subjectKey;

  /// Название так, как его показывать.
  final String subject;

  /// Профильный предмет: пропуск считается строже.
  final bool isMajor;

  /// Что взять на пару — по одному пункту в строке.
  final String items;
  final String? note;
  const SubjectProfile(
      {required this.id,
      required this.groupName,
      required this.subjectKey,
      required this.subject,
      required this.isMajor,
      required this.items,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_name'] = Variable<String>(groupName);
    map['subject_key'] = Variable<String>(subjectKey);
    map['subject'] = Variable<String>(subject);
    map['is_major'] = Variable<bool>(isMajor);
    map['items'] = Variable<String>(items);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  SubjectProfilesCompanion toCompanion(bool nullToAbsent) {
    return SubjectProfilesCompanion(
      id: Value(id),
      groupName: Value(groupName),
      subjectKey: Value(subjectKey),
      subject: Value(subject),
      isMajor: Value(isMajor),
      items: Value(items),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory SubjectProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubjectProfile(
      id: serializer.fromJson<int>(json['id']),
      groupName: serializer.fromJson<String>(json['groupName']),
      subjectKey: serializer.fromJson<String>(json['subjectKey']),
      subject: serializer.fromJson<String>(json['subject']),
      isMajor: serializer.fromJson<bool>(json['isMajor']),
      items: serializer.fromJson<String>(json['items']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupName': serializer.toJson<String>(groupName),
      'subjectKey': serializer.toJson<String>(subjectKey),
      'subject': serializer.toJson<String>(subject),
      'isMajor': serializer.toJson<bool>(isMajor),
      'items': serializer.toJson<String>(items),
      'note': serializer.toJson<String?>(note),
    };
  }

  SubjectProfile copyWith(
          {int? id,
          String? groupName,
          String? subjectKey,
          String? subject,
          bool? isMajor,
          String? items,
          Value<String?> note = const Value.absent()}) =>
      SubjectProfile(
        id: id ?? this.id,
        groupName: groupName ?? this.groupName,
        subjectKey: subjectKey ?? this.subjectKey,
        subject: subject ?? this.subject,
        isMajor: isMajor ?? this.isMajor,
        items: items ?? this.items,
        note: note.present ? note.value : this.note,
      );
  SubjectProfile copyWithCompanion(SubjectProfilesCompanion data) {
    return SubjectProfile(
      id: data.id.present ? data.id.value : this.id,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      subjectKey:
          data.subjectKey.present ? data.subjectKey.value : this.subjectKey,
      subject: data.subject.present ? data.subject.value : this.subject,
      isMajor: data.isMajor.present ? data.isMajor.value : this.isMajor,
      items: data.items.present ? data.items.value : this.items,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubjectProfile(')
          ..write('id: $id, ')
          ..write('groupName: $groupName, ')
          ..write('subjectKey: $subjectKey, ')
          ..write('subject: $subject, ')
          ..write('isMajor: $isMajor, ')
          ..write('items: $items, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, groupName, subjectKey, subject, isMajor, items, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubjectProfile &&
          other.id == this.id &&
          other.groupName == this.groupName &&
          other.subjectKey == this.subjectKey &&
          other.subject == this.subject &&
          other.isMajor == this.isMajor &&
          other.items == this.items &&
          other.note == this.note);
}

class SubjectProfilesCompanion extends UpdateCompanion<SubjectProfile> {
  final Value<int> id;
  final Value<String> groupName;
  final Value<String> subjectKey;
  final Value<String> subject;
  final Value<bool> isMajor;
  final Value<String> items;
  final Value<String?> note;
  const SubjectProfilesCompanion({
    this.id = const Value.absent(),
    this.groupName = const Value.absent(),
    this.subjectKey = const Value.absent(),
    this.subject = const Value.absent(),
    this.isMajor = const Value.absent(),
    this.items = const Value.absent(),
    this.note = const Value.absent(),
  });
  SubjectProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String groupName,
    required String subjectKey,
    required String subject,
    this.isMajor = const Value.absent(),
    this.items = const Value.absent(),
    this.note = const Value.absent(),
  })  : groupName = Value(groupName),
        subjectKey = Value(subjectKey),
        subject = Value(subject);
  static Insertable<SubjectProfile> custom({
    Expression<int>? id,
    Expression<String>? groupName,
    Expression<String>? subjectKey,
    Expression<String>? subject,
    Expression<bool>? isMajor,
    Expression<String>? items,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupName != null) 'group_name': groupName,
      if (subjectKey != null) 'subject_key': subjectKey,
      if (subject != null) 'subject': subject,
      if (isMajor != null) 'is_major': isMajor,
      if (items != null) 'items': items,
      if (note != null) 'note': note,
    });
  }

  SubjectProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? groupName,
      Value<String>? subjectKey,
      Value<String>? subject,
      Value<bool>? isMajor,
      Value<String>? items,
      Value<String?>? note}) {
    return SubjectProfilesCompanion(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      subjectKey: subjectKey ?? this.subjectKey,
      subject: subject ?? this.subject,
      isMajor: isMajor ?? this.isMajor,
      items: items ?? this.items,
      note: note ?? this.note,
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
    if (subjectKey.present) {
      map['subject_key'] = Variable<String>(subjectKey.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (isMajor.present) {
      map['is_major'] = Variable<bool>(isMajor.value);
    }
    if (items.present) {
      map['items'] = Variable<String>(items.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectProfilesCompanion(')
          ..write('id: $id, ')
          ..write('groupName: $groupName, ')
          ..write('subjectKey: $subjectKey, ')
          ..write('subject: $subject, ')
          ..write('isMajor: $isMajor, ')
          ..write('items: $items, ')
          ..write('note: $note')
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
  late final $HomeworksTable homeworks = $HomeworksTable(this);
  late final $AttendancesTable attendances = $AttendancesTable(this);
  late final $SubjectProfilesTable subjectProfiles =
      $SubjectProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        lessons,
        substitutions,
        appMeta,
        homeworks,
        attendances,
        subjectProfiles
      ];
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
typedef $$HomeworksTableCreateCompanionBuilder = HomeworksCompanion Function({
  Value<int> id,
  required String groupName,
  required String subject,
  required String description,
  required DateTime dueDate,
  Value<HomeworkPriority> priority,
  Value<bool> isDone,
  Value<DateTime> createdAt,
});
typedef $$HomeworksTableUpdateCompanionBuilder = HomeworksCompanion Function({
  Value<int> id,
  Value<String> groupName,
  Value<String> subject,
  Value<String> description,
  Value<DateTime> dueDate,
  Value<HomeworkPriority> priority,
  Value<bool> isDone,
  Value<DateTime> createdAt,
});

class $$HomeworksTableFilterComposer
    extends Composer<_$AppDatabase, $HomeworksTable> {
  $$HomeworksTableFilterComposer({
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

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<HomeworkPriority, HomeworkPriority, int>
      get priority => $composableBuilder(
          column: $table.priority,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isDone => $composableBuilder(
      column: $table.isDone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$HomeworksTableOrderingComposer
    extends Composer<_$AppDatabase, $HomeworksTable> {
  $$HomeworksTableOrderingComposer({
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

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDone => $composableBuilder(
      column: $table.isDone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$HomeworksTableAnnotationComposer
    extends Composer<_$AppDatabase, $HomeworksTable> {
  $$HomeworksTableAnnotationComposer({
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

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HomeworkPriority, int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HomeworksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HomeworksTable,
    Homework,
    $$HomeworksTableFilterComposer,
    $$HomeworksTableOrderingComposer,
    $$HomeworksTableAnnotationComposer,
    $$HomeworksTableCreateCompanionBuilder,
    $$HomeworksTableUpdateCompanionBuilder,
    (Homework, BaseReferences<_$AppDatabase, $HomeworksTable, Homework>),
    Homework,
    PrefetchHooks Function()> {
  $$HomeworksTableTableManager(_$AppDatabase db, $HomeworksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HomeworksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HomeworksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HomeworksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> groupName = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<HomeworkPriority> priority = const Value.absent(),
            Value<bool> isDone = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              HomeworksCompanion(
            id: id,
            groupName: groupName,
            subject: subject,
            description: description,
            dueDate: dueDate,
            priority: priority,
            isDone: isDone,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String groupName,
            required String subject,
            required String description,
            required DateTime dueDate,
            Value<HomeworkPriority> priority = const Value.absent(),
            Value<bool> isDone = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              HomeworksCompanion.insert(
            id: id,
            groupName: groupName,
            subject: subject,
            description: description,
            dueDate: dueDate,
            priority: priority,
            isDone: isDone,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HomeworksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HomeworksTable,
    Homework,
    $$HomeworksTableFilterComposer,
    $$HomeworksTableOrderingComposer,
    $$HomeworksTableAnnotationComposer,
    $$HomeworksTableCreateCompanionBuilder,
    $$HomeworksTableUpdateCompanionBuilder,
    (Homework, BaseReferences<_$AppDatabase, $HomeworksTable, Homework>),
    Homework,
    PrefetchHooks Function()>;
typedef $$AttendancesTableCreateCompanionBuilder = AttendancesCompanion
    Function({
  Value<int> id,
  required DateTime date,
  required String groupName,
  required int pairNumber,
  Value<String> subgroup,
  required String subject,
  required AttendanceStatus status,
  Value<DateTime> markedAt,
});
typedef $$AttendancesTableUpdateCompanionBuilder = AttendancesCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> groupName,
  Value<int> pairNumber,
  Value<String> subgroup,
  Value<String> subject,
  Value<AttendanceStatus> status,
  Value<DateTime> markedAt,
});

class $$AttendancesTableFilterComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<AttendanceStatus, AttendanceStatus, int>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get markedAt => $composableBuilder(
      column: $table.markedAt, builder: (column) => ColumnFilters(column));
}

class $$AttendancesTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableOrderingComposer({
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

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get markedAt => $composableBuilder(
      column: $table.markedAt, builder: (column) => ColumnOrderings(column));
}

class $$AttendancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<AttendanceStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get markedAt =>
      $composableBuilder(column: $table.markedAt, builder: (column) => column);
}

class $$AttendancesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttendancesTable,
    Attendance,
    $$AttendancesTableFilterComposer,
    $$AttendancesTableOrderingComposer,
    $$AttendancesTableAnnotationComposer,
    $$AttendancesTableCreateCompanionBuilder,
    $$AttendancesTableUpdateCompanionBuilder,
    (Attendance, BaseReferences<_$AppDatabase, $AttendancesTable, Attendance>),
    Attendance,
    PrefetchHooks Function()> {
  $$AttendancesTableTableManager(_$AppDatabase db, $AttendancesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> groupName = const Value.absent(),
            Value<int> pairNumber = const Value.absent(),
            Value<String> subgroup = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<AttendanceStatus> status = const Value.absent(),
            Value<DateTime> markedAt = const Value.absent(),
          }) =>
              AttendancesCompanion(
            id: id,
            date: date,
            groupName: groupName,
            pairNumber: pairNumber,
            subgroup: subgroup,
            subject: subject,
            status: status,
            markedAt: markedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required String groupName,
            required int pairNumber,
            Value<String> subgroup = const Value.absent(),
            required String subject,
            required AttendanceStatus status,
            Value<DateTime> markedAt = const Value.absent(),
          }) =>
              AttendancesCompanion.insert(
            id: id,
            date: date,
            groupName: groupName,
            pairNumber: pairNumber,
            subgroup: subgroup,
            subject: subject,
            status: status,
            markedAt: markedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AttendancesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttendancesTable,
    Attendance,
    $$AttendancesTableFilterComposer,
    $$AttendancesTableOrderingComposer,
    $$AttendancesTableAnnotationComposer,
    $$AttendancesTableCreateCompanionBuilder,
    $$AttendancesTableUpdateCompanionBuilder,
    (Attendance, BaseReferences<_$AppDatabase, $AttendancesTable, Attendance>),
    Attendance,
    PrefetchHooks Function()>;
typedef $$SubjectProfilesTableCreateCompanionBuilder = SubjectProfilesCompanion
    Function({
  Value<int> id,
  required String groupName,
  required String subjectKey,
  required String subject,
  Value<bool> isMajor,
  Value<String> items,
  Value<String?> note,
});
typedef $$SubjectProfilesTableUpdateCompanionBuilder = SubjectProfilesCompanion
    Function({
  Value<int> id,
  Value<String> groupName,
  Value<String> subjectKey,
  Value<String> subject,
  Value<bool> isMajor,
  Value<String> items,
  Value<String?> note,
});

class $$SubjectProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectProfilesTable> {
  $$SubjectProfilesTableFilterComposer({
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

  ColumnFilters<String> get subjectKey => $composableBuilder(
      column: $table.subjectKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isMajor => $composableBuilder(
      column: $table.isMajor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get items => $composableBuilder(
      column: $table.items, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$SubjectProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectProfilesTable> {
  $$SubjectProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get subjectKey => $composableBuilder(
      column: $table.subjectKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isMajor => $composableBuilder(
      column: $table.isMajor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get items => $composableBuilder(
      column: $table.items, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$SubjectProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectProfilesTable> {
  $$SubjectProfilesTableAnnotationComposer({
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

  GeneratedColumn<String> get subjectKey => $composableBuilder(
      column: $table.subjectKey, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<bool> get isMajor =>
      $composableBuilder(column: $table.isMajor, builder: (column) => column);

  GeneratedColumn<String> get items =>
      $composableBuilder(column: $table.items, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$SubjectProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubjectProfilesTable,
    SubjectProfile,
    $$SubjectProfilesTableFilterComposer,
    $$SubjectProfilesTableOrderingComposer,
    $$SubjectProfilesTableAnnotationComposer,
    $$SubjectProfilesTableCreateCompanionBuilder,
    $$SubjectProfilesTableUpdateCompanionBuilder,
    (
      SubjectProfile,
      BaseReferences<_$AppDatabase, $SubjectProfilesTable, SubjectProfile>
    ),
    SubjectProfile,
    PrefetchHooks Function()> {
  $$SubjectProfilesTableTableManager(
      _$AppDatabase db, $SubjectProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> groupName = const Value.absent(),
            Value<String> subjectKey = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<bool> isMajor = const Value.absent(),
            Value<String> items = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              SubjectProfilesCompanion(
            id: id,
            groupName: groupName,
            subjectKey: subjectKey,
            subject: subject,
            isMajor: isMajor,
            items: items,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String groupName,
            required String subjectKey,
            required String subject,
            Value<bool> isMajor = const Value.absent(),
            Value<String> items = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              SubjectProfilesCompanion.insert(
            id: id,
            groupName: groupName,
            subjectKey: subjectKey,
            subject: subject,
            isMajor: isMajor,
            items: items,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SubjectProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubjectProfilesTable,
    SubjectProfile,
    $$SubjectProfilesTableFilterComposer,
    $$SubjectProfilesTableOrderingComposer,
    $$SubjectProfilesTableAnnotationComposer,
    $$SubjectProfilesTableCreateCompanionBuilder,
    $$SubjectProfilesTableUpdateCompanionBuilder,
    (
      SubjectProfile,
      BaseReferences<_$AppDatabase, $SubjectProfilesTable, SubjectProfile>
    ),
    SubjectProfile,
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
  $$HomeworksTableTableManager get homeworks =>
      $$HomeworksTableTableManager(_db, _db.homeworks);
  $$AttendancesTableTableManager get attendances =>
      $$AttendancesTableTableManager(_db, _db.attendances);
  $$SubjectProfilesTableTableManager get subjectProfiles =>
      $$SubjectProfilesTableTableManager(_db, _db.subjectProfiles);
}
