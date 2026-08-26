import 'package:drift/drift.dart' show Migrator;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/database/database.dart';
import 'package:raspisanie_app/features/homework/data/repositories/homework_repository_impl.dart';
import 'package:raspisanie_app/features/homework/domain/homework_priority_ui.dart';

void main() {
  group('приоритет', () {
    test('о необязательных заданиях не напоминаем', () {
      expect(HomeworkPriority.optional.deservesReminder, isFalse);
      expect(HomeworkPriority.normal.deservesReminder, isTrue);
      expect(HomeworkPriority.required.deservesReminder, isTrue);
    });

    test('у каждого приоритета есть подпись', () {
      for (final priority in HomeworkPriority.values) {
        expect(priority.label, isNotEmpty);
        expect(priority.shortLabel, isNotEmpty);
      }
    });
  });

  group('подпись срока', () {
    final now = DateTime(2026, 9, 10, 14, 30);

    test('сегодня и завтра', () {
      expect(dueCaption(DateTime(2026, 9, 10), now), 'сегодня');
      expect(dueCaption(DateTime(2026, 9, 11), now), 'завтра');
      expect(dueCaption(DateTime(2026, 9, 12), now), 'послезавтра');
    });

    test('просроченное помечается', () {
      expect(dueCaption(DateTime(2026, 9, 9), now), 'просрочено');
    });

    test('склонение дней', () {
      expect(dueCaption(DateTime(2026, 9, 13), now), 'через 3 дня');
      expect(dueCaption(DateTime(2026, 9, 15), now), 'через 5 дней');
      expect(dueCaption(DateTime(2026, 9, 21), now), 'через 11 дней');
    });
  });

  group('миграция схемы', () {
    test('переход с версии 1 создаёт таблицу домашки, не трогая расписание',
        () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      // Имитируем базу версии 1: расписание есть, таблицы домашки нет.
      await database.customStatement('DROP TABLE IF EXISTS homeworks');
      await database.replaceLessons([
        LessonsCompanion.insert(
          groupName: 'СА-2124',
          dayOfWeek: 1,
          pairNumber: 1,
          subject: 'Сети',
        ),
      ]);

      await database.migration.onUpgrade(Migrator(database), 1, 2);

      // Домашка теперь пишется, а расписание на месте.
      final repository = HomeworkRepositoryImpl(database);
      await repository.add(
        groupName: 'СА-2124',
        subject: 'Сети',
        description: 'Лабораторная 1',
        dueDate: DateTime(2026, 9, 20),
        priority: HomeworkPriority.required,
      );

      expect(await repository.watch(groupName: 'СА-2124').first, hasLength(1));
      expect(await database.countLessons(), 1);
    });
  });

  group('хранение', () {
    late AppDatabase database;
    late HomeworkRepositoryImpl repository;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = HomeworkRepositoryImpl(database);
    });

    tearDown(() => database.close());

    Future<void> addTask({
      String subject = 'Математика',
      String description = 'Задачи 1–5',
      DateTime? due,
      HomeworkPriority priority = HomeworkPriority.normal,
    }) =>
        repository.add(
          groupName: 'СА-2124',
          subject: subject,
          description: description,
          dueDate: due ?? DateTime(2026, 9, 15),
          priority: priority,
        );

    test('задание сохраняется и попадает в поток', () async {
      await addTask();

      final items = await repository.watch(groupName: 'СА-2124').first;
      expect(items, hasLength(1));
      expect(items.single.subject, 'Математика');
      expect(items.single.isDone, isFalse);
    });

    test('срок обрезается до полуночи', () async {
      await addTask(due: DateTime(2026, 9, 15, 23, 47));

      final item = (await repository.watch(groupName: 'СА-2124').first).single;
      expect(item.dueDate, DateTime(2026, 9, 15));
    });

    test('сделанные скрыты, пока их не попросят', () async {
      await addTask();
      final item = (await repository.watch(groupName: 'СА-2124').first).single;
      await repository.setDone(item.id, true);

      expect(await repository.watch(groupName: 'СА-2124').first, isEmpty);
      expect(
        await repository.watch(groupName: 'СА-2124', includeDone: true).first,
        hasLength(1),
      );
    });

    test('задания чужой группы не видны', () async {
      await addTask();
      await repository.add(
        groupName: 'СА-2125',
        subject: 'Физика',
        description: 'Параграф 3',
        dueDate: DateTime(2026, 9, 16),
        priority: HomeworkPriority.required,
      );

      final items = await repository.watch(groupName: 'СА-2124').first;
      expect(items, hasLength(1));
      expect(items.single.subject, 'Математика');
    });

    test('сортировка: ближний срок первым', () async {
      await addTask(subject: 'Позже', due: DateTime(2026, 9, 20));
      await addTask(subject: 'Раньше', due: DateTime(2026, 9, 12));

      final items = await repository.watch(groupName: 'СА-2124').first;
      expect(items.map((h) => h.subject), ['Раньше', 'Позже']);
    });

    test('в один день обязательное идёт выше необязательного', () async {
      final day = DateTime(2026, 9, 14);
      await addTask(
        subject: 'Необязательное',
        due: day,
        priority: HomeworkPriority.optional,
      );
      await addTask(
        subject: 'Обязательное',
        due: day,
        priority: HomeworkPriority.required,
      );

      final items = await repository.watch(groupName: 'СА-2124').first;
      expect(items.first.subject, 'Обязательное');
    });

    test('счётчик по предметам не учитывает сделанные', () async {
      await addTask(subject: 'Математика');
      await addTask(subject: 'Математика', description: 'Ещё задачи');
      await addTask(subject: 'Физика');

      final done = (await repository.watch(groupName: 'СА-2124').first)
          .firstWhere((h) => h.subject == 'Физика');
      await repository.setDone(done.id, true);

      final counts = await repository.watchCountsBySubject('СА-2124').first;
      expect(counts['математика'], 2);
      expect(counts.containsKey('физика'), isFalse);
    });

    test('удаление убирает задание', () async {
      await addTask();
      final item = (await repository.watch(groupName: 'СА-2124').first).single;

      await repository.remove(item.id);
      expect(await repository.watch(groupName: 'СА-2124').first, isEmpty);
    });

    test('pending отдаёт только невыполненные', () async {
      await addTask(subject: 'Первое');
      await addTask(subject: 'Второе');
      final items = await repository.watch(groupName: 'СА-2124').first;
      await repository.setDone(items.first.id, true);

      final pending = await repository.pending('СА-2124');
      expect(pending, hasLength(1));
      expect(pending.single.isDone, isFalse);
    });
  });
}
