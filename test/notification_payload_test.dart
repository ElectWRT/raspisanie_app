import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/notifications/notification_service.dart';

void main() {
  group('NotificationPayload', () {
    test('дата пары кодируется без времени', () {
      final payload =
          NotificationPayload.forLesson(DateTime(2026, 9, 1, 14, 30));
      expect(payload, 'lesson:2026-09-01');
    });

    test('однозначные месяц и день дополняются нулём', () {
      final payload = NotificationPayload.forLesson(DateTime(2026, 3, 5));
      expect(payload, 'lesson:2026-03-05');
    });

    test('id домашки кодируется как есть', () {
      expect(NotificationPayload.forHomework(42), 'homework:42');
    });

    test('замены кодируются той же датой, что и пары', () {
      final date = DateTime(2026, 9, 1);
      expect(
        NotificationPayload.forSubstitutions(date),
        NotificationPayload.forLesson(date).replaceFirst('lesson', 'substitutions'),
      );
    });

    test('закодированная дата разбирается обратно DateTime.tryParse', () {
      final payload = NotificationPayload.forLesson(DateTime(2026, 12, 25));
      final data = payload.split(':').sublist(1).join(':');
      expect(DateTime.tryParse(data), DateTime(2026, 12, 25));
    });
  });

  group('payload у напоминаний', () {
    test('LessonReminder ссылается на день пары, а не на момент звонка', () {
      // Напоминание приходит за N минут до звонка, но открыть должно
      // именно тот день, на который назначена пара.
      final reminder = LessonReminder(
        when: DateTime(2026, 9, 1, 8, 15),
        date: DateTime(2026, 9, 1),
        bellTime: '08:30',
        minutesBefore: 15,
        subject: 'Физика',
        pairNumber: 1,
      );

      expect(reminder.payload, 'lesson:2026-09-01');
    });

    test('HomeworkReminder ссылается на id задания', () {
      final reminder = HomeworkReminder(
        when: DateTime(2026, 9, 1, 19),
        homeworkId: 7,
        subject: 'История',
        description: 'Параграф 5',
        daysLeft: 1,
        priorityLabel: 'Обязательно',
      );

      expect(reminder.payload, 'homework:7');
    });
  });
}
