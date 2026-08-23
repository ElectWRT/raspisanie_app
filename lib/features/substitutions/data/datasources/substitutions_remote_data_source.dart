import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;

import '../../../../core/error/exceptions.dart';

/// Ссылка на документ с заменами, найденная на сайте учебного заведения.
class SourceLink {
  final String url;
  final String title;

  /// Дата, распознанная в тексте ссылки. null — не удалось определить.
  final DateTime? date;

  const SourceLink({required this.url, required this.title, this.date});

  bool get isCloudMail => url.contains('cloud.mail.ru');

  bool get isDirectDocument =>
      RegExp(r'\.docx?(?:$|\?)', caseSensitive: false).hasMatch(url);
}

abstract class SubstitutionsRemoteDataSource {
  /// Все ссылки со страницы, похожие на замены.
  Future<List<SourceLink>> findLinks(String pageUrl);

  /// Скачивает документ. Понимает публичные ссылки cloud.mail.ru,
  /// ссылки на папку в облаке и прямые ссылки на файл.
  Future<Uint8List> download(String url);
}

class SubstitutionsRemoteDataSourceImpl implements SubstitutionsRemoteDataSource {
  SubstitutionsRemoteDataSourceImpl(this.dio);

  final Dio dio;

  static const _dispatcherUrl = 'https://cloud.mail.ru/api/v2/dispatcher';
  static const _folderApiUrl = 'https://cloud.mail.ru/api/v2/folder';

  static const Map<String, dynamic> _headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
    'Accept': '*/*',
    'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
  };

  static const List<String> _monthStems = [
    'январ',
    'феврал',
    'март',
    'апрел',
    'ма',
    'июн',
    'июл',
    'август',
    'сентябр',
    'октябр',
    'ноябр',
    'декабр',
  ];

  static final RegExp _substitutionWord =
      RegExp(r'замен', caseSensitive: false);
  static final RegExp _numericDate =
      RegExp(r'(\d{1,2})[.\-/](\d{1,2})(?:[.\-/](\d{2,4}))?');
  static final RegExp _textualDate = RegExp(
    r'(\d{1,2})\s+(январ|феврал|март|апрел|ма[йя]|июн|июл|август|сентябр|октябр|ноябр|декабр)\w*',
    caseSensitive: false,
  );

  @override
  Future<List<SourceLink>> findLinks(String pageUrl) async {
    final Response<dynamic> response;
    try {
      response = await dio.get<dynamic>(
        pageUrl,
        options: Options(headers: _headers, responseType: ResponseType.plain),
      );
    } catch (e) {
      throw NetworkException('Не удалось открыть $pageUrl: ${_short(e)}');
    }

    final document = html.parse(response.data.toString());
    final base = Uri.parse(pageUrl);
    final seen = <String>{};
    final links = <SourceLink>[];

    for (final anchor in document.querySelectorAll('a[href]')) {
      final href = anchor.attributes['href']!.trim();
      if (href.isEmpty || href.startsWith('#')) continue;

      // Текст самой ссылки часто скупой («скачать»), поэтому берём и
      // текст ближайшего блока — там обычно и стоит дата.
      final anchorText = anchor.text.trim();
      final contextText = (anchor.parent?.text ?? anchorText).trim();
      if (!_substitutionWord.hasMatch(contextText) &&
          !_substitutionWord.hasMatch(href)) {
        continue;
      }

      final absolute = base.resolve(href).toString();
      if (!seen.add(absolute)) continue;

      links.add(SourceLink(
        url: absolute,
        title: _collapse(anchorText.isEmpty ? contextText : anchorText),
        date: parseDate(contextText),
      ));
    }

    if (links.isEmpty) {
      throw ParsingException(
        'На странице не нашлось ссылок со словом «замены». '
        'Проверьте адрес страницы в настройках или укажите прямую ссылку.',
      );
    }
    return links;
  }

  @override
  Future<Uint8List> download(String url) async {
    final target = url.contains('cloud.mail.ru') ? await _resolveMailRu(url) : url;
    try {
      final response = await dio.get<List<int>>(
        target,
        options: Options(headers: _headers, responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data ?? const []);
      if (bytes.length < 4 || bytes[0] != 0x50 || bytes[1] != 0x4B) {
        throw ParsingException(
          'Скачался не .docx. Похоже, ссылка ведёт на страницу, а не на файл.',
        );
      }
      return bytes;
    } on ParsingException {
      rethrow;
    } catch (e) {
      throw NetworkException('Ошибка загрузки файла: ${_short(e)}');
    }
  }

  // ------------------------------------------------------------ cloud.mail.ru

  /// Публичная ссылка вида `https://cloud.mail.ru/public/AbCd/file.docx`
  /// превращается в прямую через официальный dispatcher облака.
  Future<String> _resolveMailRu(String publicUrl) async {
    final path = _publicPath(publicUrl);
    if (path == null) {
      throw ParsingException('Не похоже на публичную ссылку cloud.mail.ru.');
    }

    final host = await _weblinkHost();
    final filePath = await _resolveFileInsideFolder(path);
    return '$host/${Uri.encodeFull(filePath)}';
  }

  /// Адрес раздающего сервера облака.
  Future<String> _weblinkHost() async {
    try {
      final response = await dio.get<dynamic>(
        _dispatcherUrl,
        queryParameters: const {'api': 2},
        options: Options(headers: _headers, responseType: ResponseType.plain),
      );
      final body = jsonDecode(response.data.toString())['body'];
      final url = (body?['weblink_get'] as List?)?.first?['url'] as String?;
      if (url == null || url.isEmpty) {
        throw ParsingException('Облако не вернуло адрес для скачивания.');
      }
      return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    } on ParsingException {
      rethrow;
    } catch (e) {
      throw NetworkException('Облако Mail.ru недоступно: ${_short(e)}');
    }
  }

  /// Если ссылка ведёт на папку — находим внутри свежий .docx.
  /// Если на файл — возвращаем путь как есть.
  Future<String> _resolveFileInsideFolder(String path) async {
    if (RegExp(r'\.docx?$', caseSensitive: false).hasMatch(path)) return path;

    final Map<String, dynamic> body;
    try {
      final response = await dio.get<dynamic>(
        _folderApiUrl,
        queryParameters: {'weblink': path, 'api': 2},
        options: Options(headers: _headers, responseType: ResponseType.plain),
      );
      body = jsonDecode(response.data.toString())['body'] as Map<String, dynamic>;
    } catch (_) {
      // Не папка (или API отказал) — пробуем скачать как файл.
      return path;
    }

    final entries = (body['list'] as List?) ?? const [];
    final docs = entries
        .whereType<Map<String, dynamic>>()
        .where((e) =>
            e['type'] == 'file' &&
            RegExp(r'\.docx?$', caseSensitive: false)
                .hasMatch((e['name'] as String?) ?? ''))
        .toList();

    if (docs.isEmpty) {
      throw ParsingException('В папке облака нет ни одного .docx.');
    }

    docs.sort((a, b) =>
        ((b['mtime'] as num?) ?? 0).compareTo((a['mtime'] as num?) ?? 0));
    return (docs.first['weblink'] as String?) ??
        '$path/${docs.first['name']}';
  }

  /// `https://cloud.mail.ru/public/AbCd/EfGh/file.docx` → `AbCd/EfGh/file.docx`
  static String? _publicPath(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final segments = uri.pathSegments;
    final index = segments.indexOf('public');
    if (index == -1 || index + 1 >= segments.length) return null;
    return segments.sublist(index + 1).join('/');
  }

  // ----------------------------------------------------------------- helpers

  /// Ищет дату в тексте: «Замены на 5 сентября» или «Замены 05.09.2026».
  static DateTime? parseDate(String text, {DateTime? now}) {
    final today = now ?? DateTime.now();

    final textual = _textualDate.firstMatch(text);
    if (textual != null) {
      final day = int.parse(textual.group(1)!);
      final stem = textual.group(2)!.toLowerCase();
      final month = _monthStems.indexWhere(stem.startsWith) + 1;
      if (month > 0) {
        return _withNearestYear(day: day, month: month, today: today);
      }
    }

    final numeric = _numericDate.firstMatch(text);
    if (numeric != null) {
      final day = int.parse(numeric.group(1)!);
      final month = int.parse(numeric.group(2)!);
      if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
        final rawYear = int.tryParse(numeric.group(3) ?? '');
        if (rawYear != null) {
          return DateTime(rawYear < 100 ? rawYear + 2000 : rawYear, month, day);
        }
        return _withNearestYear(day: day, month: month, today: today);
      }
    }
    return null;
  }

  /// В тексте ссылки год обычно не пишут. Берём тот, при котором дата
  /// оказывается ближе всего к сегодняшнему дню.
  static DateTime _withNearestYear({
    required int day,
    required int month,
    required DateTime today,
  }) {
    final candidates = [
      DateTime(today.year - 1, month, day),
      DateTime(today.year, month, day),
      DateTime(today.year + 1, month, day),
    ];
    candidates.sort((a, b) => a
        .difference(today)
        .abs()
        .compareTo(b.difference(today).abs()));
    return candidates.first;
  }

  static String _collapse(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _short(Object error) {
    if (error is DioException) {
      return error.response?.statusCode != null
          ? 'HTTP ${error.response!.statusCode}'
          : (error.message ?? error.type.name);
    }
    return error.toString();
  }
}
