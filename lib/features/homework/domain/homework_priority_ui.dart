import 'package:flutter/material.dart';

import '../../../core/database/tables.dart';

/// Как приоритет выглядит и называется в интерфейсе.
extension HomeworkPriorityUi on HomeworkPriority {
  String get label => switch (this) {
        HomeworkPriority.required => 'Обязательно',
        HomeworkPriority.normal => 'Желательно',
        HomeworkPriority.optional => 'Не критично',
      };

  String get shortLabel => switch (this) {
        HomeworkPriority.required => 'обяз.',
        HomeworkPriority.normal => 'жел.',
        HomeworkPriority.optional => 'необяз.',
      };

  IconData get icon => switch (this) {
        HomeworkPriority.required => Icons.priority_high,
        HomeworkPriority.normal => Icons.drag_handle,
        HomeworkPriority.optional => Icons.low_priority,
      };

  /// Цвет берём из схемы темы, чтобы он жил и в светлой, и в тёмной.
  Color color(ColorScheme scheme) => switch (this) {
        HomeworkPriority.required => scheme.error,
        HomeworkPriority.normal => scheme.primary,
        HomeworkPriority.optional => scheme.outline,
      };

  /// Напоминать ли о задании. О необязательном не дёргаем.
  bool get deservesReminder => this != HomeworkPriority.optional;
}

/// Человеческая подпись срока: «сегодня», «завтра», «через 3 дня».
String dueCaption(DateTime due, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(due.year, due.month, due.day);
  final days = target.difference(today).inDays;

  return switch (days) {
    < 0 => 'просрочено',
    0 => 'сегодня',
    1 => 'завтра',
    2 => 'послезавтра',
    _ => 'через $days ${_daysWord(days)}',
  };
}

String _daysWord(int days) {
  final mod10 = days % 10;
  final mod100 = days % 100;
  if (mod10 == 1 && mod100 != 11) return 'день';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'дня';
  return 'дней';
}
