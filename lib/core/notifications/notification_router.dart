import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di.dart';
import '../../features/homework/presentation/bloc/homework_cubit.dart';
import '../../features/homework/presentation/pages/homework_page.dart';
import '../../features/schedule/domain/repositories/schedule_repository.dart';
import '../../features/schedule/presentation/bloc/schedule_cubit.dart';
import '../../features/substitutions/presentation/pages/substitutions_page.dart';
import '../settings/app_settings.dart';
import 'notification_service.dart';

/// Открывает нужный экран по тапу на уведомление, вместо того чтобы просто
/// вывести на главный экран и заставить искать нужный день или задание
/// заново.
class NotificationRouter {
  const NotificationRouter._();

  static Future<void> handle(BuildContext context, String payload) async {
    final parts = payload.split(':');
    if (parts.length < 2) return;

    final type = parts[0];
    final data = parts.sublist(1).join(':');
    final navigator = Navigator.of(context);

    // Уведомление всегда должно открывать нужное поверх главного экрана,
    // а не поверх того, что человек листал в приложении до этого.
    navigator.popUntil((route) => route.isFirst);

    switch (type) {
      case NotificationPayload.lessonType:
        final date = DateTime.tryParse(data);
        if (date == null) return;
        context.read<ScheduleCubit>().selectDate(date);

      case NotificationPayload.substitutionsType:
        final date = DateTime.tryParse(data);
        if (date == null) return;
        navigator.push(
          MaterialPageRoute(builder: (_) => SubstitutionsPage(date: date)),
        );

      case NotificationPayload.homeworkType:
        final id = int.tryParse(data);
        if (id == null) return;
        await _openHomework(context, highlightId: id);

      // Отмечают прямо в списке пар, поэтому ведём на нужный день, а не
      // на экран статистики: там отмечать нечего.
      case NotificationPayload.attendanceType:
        final date = DateTime.tryParse(data);
        if (date == null) return;
        context.read<ScheduleCubit>().selectDate(date);
    }
  }

  static Future<void> _openHomework(
    BuildContext context, {
    required int highlightId,
  }) async {
    final homeworkCubit = context.read<HomeworkCubit>();
    final group = getIt<AppSettings>().selectedGroup;

    final subjects =
        group == null ? <String>[] : await getIt<ScheduleRepository>().subjects(group);
    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: homeworkCubit,
          child: HomeworkPage(subjects: subjects, highlightId: highlightId),
        ),
      ),
    );
  }
}
