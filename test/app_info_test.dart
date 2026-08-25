import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/app_info.dart';

void main() {
  test('AppInfo.version не разъезжается с pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(r'^version:\s*([\d.]+)', multiLine: true)
        .firstMatch(pubspec);

    expect(match, isNotNull, reason: 'в pubspec.yaml не найдена строка version');
    expect(
      AppInfo.version,
      match!.group(1),
      reason: 'обновите AppInfo.version в lib/core/app_info.dart',
    );
  });
}
