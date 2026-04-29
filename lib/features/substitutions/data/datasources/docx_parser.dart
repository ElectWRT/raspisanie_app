import 'dart:io';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '../models/substitution_model.dart';
import '../../../../core/error/exceptions.dart';

class DocxParser {
  List<SubstitutionModel> parse(File docxFile) {
    try {
      final bytes = docxFile.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      final contentFile = archive.findFile('word/document.xml');
      if (contentFile == null) throw ParsingException('word/document.xml не найден');

      final document = XmlDocument.parse(String.fromCharCodes(contentFile.content));
      final List<SubstitutionModel> result = [];

      for (final table in document.findAllElements('w:tbl')) {
        for (final row in table.findElements('w:tr')) {
          final cells = row.findElements('w:tc').map((tc) => _getTableCellText(tc)).toList();

          if (cells.isNotEmpty && cells[0].startsWith('СА-')) {
            if (cells.length >= 5) {
              result.add(SubstitutionModel(
                groupName: cells[0],
                lessonNumber: int.tryParse(cells[1]) ?? 0,
                subject: cells[2],
                teacher: cells[3],
                room: cells[4],
              ));
            }
          }
        }
      }
      return result;
    } catch (e) {
      throw ParsingException('Ошибка парсинга DOCX: $e');
    }
  }

  String _getTableCellText(XmlElement tc) {
    // RECURSIVE: Collect all text nodes within the cell
    return tc.findAllElements('w:t').map((node) => node.innerText).join('').trim();
  }
}
