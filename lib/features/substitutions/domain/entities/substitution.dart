import 'package:equatable/equatable.dart';

class SubstitutionEntity extends Equatable {
  final int id;
  final String groupName;
  final String period;
  final String subject;
  final String teacher;
  final String room;

  const SubstitutionEntity({
    required this.id,
    required this.groupName,
    required this.period,
    required this.subject,
    required this.teacher,
    required this.room,
  });

  @override
  List<Object?> get props => [id, groupName, period, subject, teacher, room];
}
