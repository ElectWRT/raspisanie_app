import 'package:equatable/equatable.dart';

/// Имя преподавателя, приведённое к сравнимому виду: фамилия и инициалы.
///
/// В расписании и в документе замен одного и того же человека пишут
/// по-разному — «Иванов И.И.», «Иванов И. И.», «иванов иван иванович».
/// Сравнивать строки напрямую бессмысленно.
class TeacherName extends Equatable {
  const TeacherName({required this.surname, this.initials = const []});

  final String surname;

  /// Первые буквы имени и отчества — по одной на каждое.
  final List<String> initials;

  /// Разбирает строку. null — разобрать не удалось: пусто или одна буква,
  /// по такому сопоставлять нельзя.
  static TeacherName? parse(String raw) {
    final normalized = raw
        .toLowerCase()
        .replaceAll('ё', 'е')
        // Точки и прочие разделители превращаем в пробелы, чтобы «И.И.»
        // распалось на две отдельные буквы, а не слиплось в «ии».
        .replaceAll(RegExp(r'[^a-zа-я]+'), ' ')
        .trim();
    if (normalized.isEmpty) return null;

    final tokens = normalized.split(' ').where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return null;

    final surname = tokens.first;
    if (surname.length < 2) return null;

    return TeacherName(
      surname: surname,
      initials: tokens.skip(1).map((t) => t[0]).toList(),
    );
  }

  /// Один ли это человек.
  ///
  /// Инициалы сравниваются на общую длину: если в одном месте написано
  /// «Иванов», а в другом «Иванов И.И.», это считается совпадением —
  /// больше информации всё равно нет.
  bool matches(TeacherName other) {
    if (surname != other.surname) return false;

    final common = initials.length < other.initials.length
        ? initials.length
        : other.initials.length;
    for (var i = 0; i < common; i++) {
      if (initials[i] != other.initials[i]) return false;
    }
    return true;
  }

  @override
  List<Object?> get props => [surname, initials];
}
