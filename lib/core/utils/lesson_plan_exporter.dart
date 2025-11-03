import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter/foundation.dart';

class LessonPlanExporter {
  /// Converts markdown text to plain text, preserving basic formatting
  static String _markdownToPlainText(String markdown) {
    final document = md.Document();
    final nodes = document.parseLines(markdown.split('\n'));
    final buffer = StringBuffer();
    
    for (final node in nodes) {
      if (node is md.Element) {
        buffer.writeln(_elementToPlainText(node));
      } else if (node is md.Text) {
        buffer.writeln(node.text);
      }
    }
    
    return buffer.toString().trim();
  }

  static String _elementToPlainText(md.Element element) {
    final buffer = StringBuffer();
    
    for (final child in element.children!) {
      if (child is md.Element) {
        buffer.write(_elementToPlainText(child));
      } else if (child is md.Text) {
        buffer.write(child.text);
      }
    }
    
    return buffer.toString();
  }

  /// Gets a directory path with multiple fallback options
  static Future<Directory> _getDirectory() async {
    // Try path_provider first
    try {
      return await getTemporaryDirectory();
    } catch (e) {
      debugPrint('getTemporaryDirectory failed: $e');
    }

    // Try application documents directory
    try {
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      debugPrint('getApplicationDocumentsDirectory failed: $e');
    }

    // Fallback to system temp directory
    final sysTemp = Directory.systemTemp;
    if (await sysTemp.exists()) {
      return sysTemp;
    }

    // Create system temp if it doesn't exist
    await sysTemp.create(recursive: true);
    return sysTemp;
  }

  /// Generates a PDF file from lesson plan content
  static Future<String?> generatePDF({
    required String title,
    required String content,
  }) async {
    try {
      final pdf = pw.Document();
      
      // Parse markdown content
      final document = md.Document();
      final nodes = document.parseLines(content.split('\n'));
      
      // Build PDF widgets
      final List<pw.Widget> widgets = [];
      
      // Add title
      widgets.add(
        pw.Header(
          level: 0,
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      
      widgets.add(pw.SizedBox(height: 20));
      
      // Convert markdown to PDF widgets
      for (final node in nodes) {
        if (node is md.Element) {
          final widget = _elementToPdfWidget(node);
          if (widget != null) {
            widgets.add(widget);
            widgets.add(pw.SizedBox(height: 8));
          }
        } else if (node is md.Text) {
          widgets.add(
            pw.Text(
              node.text,
              style: const pw.TextStyle(fontSize: 12),
            ),
          );
          widgets.add(pw.SizedBox(height: 8));
        }
      }
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return widgets;
          },
        ),
      );
      
      // Save PDF to directory using fallback approach
      final directory = await _getDirectory();
      final fileName = '${title.replaceAll(RegExp(r'[^\w\s-]'), '_')}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      return filePath;
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      return null;
    }
  }

  static pw.Widget? _elementToPdfWidget(md.Element element) {
    switch (element.tag) {
      case 'h1':
        return pw.Header(
          level: 0,
          child: pw.Text(
            _getElementText(element),
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
      case 'h2':
        return pw.Header(
          level: 1,
          child: pw.Text(
            _getElementText(element),
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
      case 'h3':
        return pw.Header(
          level: 2,
          child: pw.Text(
            _getElementText(element),
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
      case 'p':
        return pw.Text(
          _getElementText(element),
          style: const pw.TextStyle(fontSize: 12),
        );
      case 'ul':
      case 'ol':
        // Use "-" instead of bullet point to avoid Unicode font issues
        return pw.Text(
          '- ${_getElementText(element)}',
          style: const pw.TextStyle(fontSize: 12),
        );
      case 'strong':
      case 'b':
        return pw.Text(
          _getElementText(element),
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        );
      case 'em':
      case 'i':
        return pw.Text(
          _getElementText(element),
          style: pw.TextStyle(
            fontSize: 12,
            fontStyle: pw.FontStyle.italic,
          ),
        );
      default:
        return pw.Text(
          _getElementText(element),
          style: const pw.TextStyle(fontSize: 12),
        );
    }
  }

  static String _getElementText(md.Element element) {
    final buffer = StringBuffer();
    for (final child in element.children!) {
      if (child is md.Element) {
        buffer.write(_getElementText(child));
      } else if (child is md.Text) {
        buffer.write(child.text);
      }
    }
    return buffer.toString();
  }

  /// Generates a DOCX file from lesson plan content
  /// Note: DOCX generation requires a backend service or more complex library
  static Future<String?> generateDOCX({
    required String title,
    required String content,
  }) async {
    // DOCX generation removed - requires backend work
    return null;
  }

  /// Generates a DOCS file (Google Docs format)
  /// Note: Google Docs format is proprietary and cloud-based
  /// We'll create a simple text document that can be imported
  static Future<String?> generateDOCS({
    required String title,
    required String content,
  }) async {
    try {
      // Convert markdown to plain text
      final plainText = _markdownToPlainText(content);
      
      // Get directory using fallback approach
      final directory = await _getDirectory();
      final fileName = '${title.replaceAll(RegExp(r'[^\w\s-]'), '_')}.txt';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      
      // Write formatted text
      await file.writeAsString('$title\n\n$plainText');
      
      return filePath;
    } catch (e) {
      debugPrint('Error generating DOCS: $e');
      return null;
    }
  }

  /// Shares/downloads the file
  /// Returns true if sharing succeeded, false if plugin not available
  static Future<bool> shareFile(String filePath, String fileName) async {
    try {
      // The share_plus package handles file sharing through the system share sheet
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: fileName,
      );
      return true;
    } catch (e) {
      debugPrint('Error sharing file: $e');
      // If it's a MissingPluginException, return false instead of throwing
      if (e.toString().contains('MissingPluginException') || 
          e.toString().contains('No implementation found')) {
        return false;
      }
      rethrow;
    }
  }
}
