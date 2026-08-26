import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ошибка в build не должна оставлять пустой экран: показываем текст,
  // по которому понятно, что чинить.
  ErrorWidget.builder = (details) => _ErrorScreen(
        message: details.exceptionAsString(),
      );

  try {
    await setupDependencies();
  } catch (error, stack) {
    debugPrint('Ошибка инициализации: $error\n$stack');
    runApp(_StartupFailureApp(message: '$error'));
    return;
  }

  runApp(const RaspisanieApp());
}

/// Показывается, когда приложение не смогло собрать зависимости —
/// например, не открылась база данных.
class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6BFF)),
        useMaterial3: true,
      ),
      home: _ErrorScreen(message: message),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Приложение не смогло запуститься',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SelectableText(
              message,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}
