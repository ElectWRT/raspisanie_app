import '../../domain/entities/substitution.dart';

class SubstitutionModel extends SubstitutionEntity {
  final int lessonNumber;

  const SubstitutionModel({
    required String groupName,
    required this.lessonNumber,
    required String subject,
    required String teacher,
    required String room,
  }) : super(
          id: 0, // Will be set by DB
          groupName: groupName,
          period: '', // Getter period will handle this
          subject: subject,
          teacher: teacher,
          room: room,
        );

  @override
  String get period => lessonNumber.toString();

  factory SubstitutionModel.fromRow(List<String> cells) {
    // Expected order: Группа, Пара, Предмет, Преподаватель, Ауд
    return SubstitutionModel(
      groupName: cells[0].trim(),
      lessonNumber: int.tryParse(cells[1].trim()) ?? 0,
      subject: cells[2].trim(),
      teacher: cells[3].trim(),
      room: cells[4].trim(),
    );
  }
}
