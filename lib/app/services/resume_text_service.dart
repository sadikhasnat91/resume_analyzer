import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart';

class ResumeTextService {
  static Future<String> extractText(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null) {
      return file.name;
    }

    final extension = file.extension?.toLowerCase() ?? '';
    switch (extension) {
      case 'docx':
        return _extractDocxText(bytes);
      case 'pdf':
        return _extractPdfText(bytes);
      case 'doc':
        return _extractDocText(bytes);
      default:
        return _normalizeText(latin1.decode(bytes, allowInvalid: true));
    }
  }

  static String _extractDocxText(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes, verify: false);
      final documentEntry = archive.files.firstWhere(
        (entry) => entry.name == 'word/document.xml',
        orElse: () => throw StateError('Missing document.xml in DOCX file.'),
      );

      final documentXml = utf8.decode(documentEntry.content as List<int>);
      final xmlDocument = XmlDocument.parse(documentXml);
      final paragraphs = xmlDocument.findAllElements('t');

      final extracted = paragraphs
          .map((node) => node.value ?? '')
          .join(' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      return extracted.isNotEmpty ? extracted : 'DOCX Resume Document';
    } catch (_) {
      return 'DOCX Resume Document';
    }
  }

  static String _extractPdfText(Uint8List bytes) {
    try {
      final pdfString = latin1.decode(bytes, allowInvalid: true);

      final textMatches = RegExp(r'\(([^)]+)\)').allMatches(pdfString);
      final extracted = textMatches
          .map((match) => match.group(1)!)
          .where((t) => t.trim().length > 1 && !t.contains('\\'))
          .join(' ');

      if (extracted.trim().length > 30) {
        return _normalizeText(extracted);
      }
    } catch (_) {}

    final rawString = latin1.decode(bytes, allowInvalid: true);
    final cleanAscii = rawString.replaceAll(RegExp(r'[^\x20-\x7E\r\n]'), ' ');
    final words = cleanAscii
        .split(RegExp(r'\s+'))
        .where((w) => RegExp(r'^[a-zA-Z0-9.,@+-]{2,}$').hasMatch(w))
        .join(' ');

    return words.length > 20 ? words : 'PDF Resume Document';
  }

  static String _extractDocText(Uint8List bytes) {
    final rawText = latin1.decode(bytes, allowInvalid: true);
    final asciiText = rawText.replaceAll(RegExp(r'[^\x20-\x7E\r\n]'), ' ');

    return _normalizeText(asciiText);
  }

  static String _normalizeText(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
