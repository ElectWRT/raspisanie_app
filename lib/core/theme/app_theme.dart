import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Вариант акцентного цвета, который пользователь выбирает в настройках.
class AccentOption {
  final String id;
  final String label;
  final Color seed;

  const AccentOption({
    required this.id,
    required this.label,
    required this.seed,
  });
}

/// Палитра акцентов. Ограниченный набор — так приложение остаётся
/// цельным, в отличие от свободного колор-пикера.
class AppAccents {
  const AppAccents._();

  static const List<AccentOption> options = [
    AccentOption(id: 'blue', label: 'Синий', seed: Color(0xFF2F6BFF)),
    AccentOption(id: 'indigo', label: 'Индиго', seed: Color(0xFF5B4BE0)),
    AccentOption(id: 'teal', label: 'Бирюзовый', seed: Color(0xFF00897B)),
    AccentOption(id: 'green', label: 'Зелёный', seed: Color(0xFF2E7D32)),
    AccentOption(id: 'orange', label: 'Оранжевый', seed: Color(0xFFE65100)),
    AccentOption(id: 'red', label: 'Красный', seed: Color(0xFFC62828)),
    AccentOption(id: 'pink', label: 'Розовый', seed: Color(0xFFC2185B)),
    AccentOption(id: 'graphite', label: 'Графит', seed: Color(0xFF4A5568)),
  ];

  static const AccentOption fallback =
      AccentOption(id: 'blue', label: 'Синий', seed: Color(0xFF2F6BFF));

  static AccentOption byId(String? id) => options.firstWhere(
        (option) => option.id == id,
        orElse: () => fallback,
      );
}

class AppTheme {
  const AppTheme._();

  /// Собирает тему приложения.
  ///
  /// [dynamicScheme] — схема из обоев системы (Android 12+). Если она есть
  /// и включена в настройках, акцент из палитры игнорируется.
  /// [amoled] красит фон в чистый чёрный — заметно экономит батарею на OLED.
  static ThemeData build({
    required Brightness brightness,
    required Color seed,
    ColorScheme? dynamicScheme,
    bool amoled = false,
  }) {
    var scheme = dynamicScheme ??
        ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    final isDark = brightness == Brightness.dark;
    if (amoled && isDark) {
      scheme = scheme.copyWith(
        surface: Colors.black,
        surfaceContainerLowest: Colors.black,
        surfaceContainerLow: const Color(0xFF0A0A0A),
        surfaceContainer: const Color(0xFF121212),
        surfaceContainerHigh: const Color(0xFF1A1A1A),
        surfaceContainerHighest: const Color(0xFF222222),
      );
    }

    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final borderRadius = BorderRadius.circular(16);

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        space: 1,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
