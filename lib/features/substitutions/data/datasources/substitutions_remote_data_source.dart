import 'dart:io';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:path_provider/path_provider.dart';
import '../../../../core/error/exceptions.dart';

abstract class SubstitutionsRemoteDataSource {
  Future<String> getMailRuLink();
  Future<String> getDirectLink(String publicUrl);
  Future<File> downloadFile(String directUrl);
}

class SubstitutionsRemoteDataSourceImpl implements SubstitutionsRemoteDataSource {
  final Dio dio;
  static const String khamkUrl = 'https://www.khamk.ru/studentu/uchebnye-plany-po-spetsialnostyam';
  
  final Map<String, dynamic> _browserHeaders = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
    'Accept': '*/*',
    'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
  };

  SubstitutionsRemoteDataSourceImpl(this.dio);

  @override
  Future<String> getMailRuLink() async {
    try {
      final response = await dio.get(khamkUrl, options: Options(headers: _browserHeaders));
      final document = parse(response.data);
      
      final listItems = document.querySelectorAll('li');
      final now = DateTime.now();
      final dateText = '${now.day} ${_getMonthName(now.month)}';

      for (final li in listItems) {
        final text = li.text.toLowerCase();
        if (text.contains('замен') && (text.contains(dateText) || text.contains(now.day.toString()))) {
          final link = li.querySelector('a');
          final href = link?.attributes['href'];
          if (href != null && href.contains('cloud.mail.ru')) {
            // Priority for Building 1
            if (text.contains('1 корпус')) return href;
          }
        }
      }
      
      // Fallback: any zamen link for today
      for (final li in listItems) {
        final text = li.text.toLowerCase();
        if (text.contains('замен') && text.contains(dateText)) {
          final href = li.querySelector('a')?.attributes['href'];
          if (href != null) return href;
        }
      }
      
      throw ParsingException('Ссылка на замены для $dateText не найдена');
    } catch (e) {
      if (e is ParsingException) rethrow;
      throw NetworkException('Ошибка скрапинга ХАМК: $e');
    }
  }

  @override
  Future<String> getDirectLink(String publicUrl) async {
    try {
      final response = await dio.get(publicUrl, options: Options(headers: _browserHeaders));
      final html = response.data.toString();

      // Find window.RENDER_DATA
      final regExp = RegExp(r'window\.RENDER_DATA\s*=\s*(?:JSON\.parse\()?(["{].*?)(?:\))?\s*;');
      final match = regExp.firstMatch(html);

      if (match == null) throw ParsingException('RENDER_DATA не найден на странице Mail.ru');

      var rawData = match.group(1)!.trim();
      if (rawData.startsWith('"')) {
        rawData = rawData.substring(1, rawData.length - 1)
            .replaceAll('\\"', '"')
            .replaceAll('\\\\', '\\')
            .replaceAll('\\/', '/');
      }

      final tokenMatch = RegExp(r'\"weblink_get\":\[?\{\"token\":\"(.*?)\"').firstMatch(rawData);
      final dispMatch = RegExp(r'\"get\":\[\{\"url\":\"(.*?)\"').firstMatch(rawData);
      
      if (tokenMatch != null && dispMatch != null) {
        final token = tokenMatch.group(1);
        final server = dispMatch.group(1);
        final id = Uri.parse(publicUrl).pathSegments.last;
        return '$server/get/$id?double_encode=1&token=$token';
      }

      throw ParsingException('Не удалось извлечь токены скачивания из RENDER_DATA');
    } catch (e) {
      if (e is ParsingException) rethrow;
      throw NetworkException('Ошибка Mail.ru API: $e');
    }
  }

  @override
  Future<File> downloadFile(String directUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/temp_substitutions.docx';
      await dio.download(directUrl, filePath, options: Options(headers: _browserHeaders));
      return File(filePath);
    } catch (e) {
      throw NetworkException('Ошибка загрузки DOCX: $e');
    }
  }

  String _getMonthName(int month) {
    const m = ['января','февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря'];
    return m[month - 1];
  }
}
