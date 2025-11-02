import 'package:markdown/markdown.dart' as md;

/// Converts markdown text to plain text by extracting only text nodes from the AST.
///
/// This function parses the markdown string into an abstract syntax tree (AST),
/// then traverses the tree to extract only the textual content, ignoring all
/// formatting syntax (headings, bold, italic, lists, code blocks, etc.).
/// Also decodes HTML entities like &quot; to actual quotes.
///
/// Example:
/// ```dart
/// final markdown = "# Heading\n**Bold text** and *italic*";
/// final plainText = stripMarkdownToText(markdown);
/// // Result: "Heading\nBold text and italic"
/// ```
///
/// [markdown] The markdown string to convert to plain text
/// Returns plain text string with all markdown syntax removed and HTML entities decoded
String stripMarkdownToText(String markdown) {
  if (markdown.isEmpty) {
    return '';
  }

  // Parse markdown into AST
  final document = md.Document();
  final nodes = document.parseLines(markdown.split('\n'));

  // Extract text from AST nodes
  final buffer = StringBuffer();
  _extractTextFromNodes(nodes, buffer);

  // Decode HTML entities and clean up
  String result = buffer.toString();

  // Decode HTML entities
  result = _decodeHtmlEntities(result);

  // Remove any remaining markdown syntax that wasn't parsed
  result = _removeRemainingMarkdownSyntax(result);

  // Clean up extra whitespace and newlines
  result = result
      .replaceAll(RegExp(r'\n{3,}'), '\n\n') // Replace 3+ newlines with 2
      .replaceAll(
        RegExp(r'[ \t]+'),
        ' ',
      ) // Replace multiple spaces/tabs with single space
      .trim();

  return result;
}

/// Decodes HTML entities to their actual characters.
String _decodeHtmlEntities(String text) {
  String result = text;

  // Common HTML entities
  result = result
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ');

  // Decode numeric entities (&#123;)
  result = result.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
    final code = int.parse(match.group(1)!);
    return String.fromCharCode(code);
  });

  // Decode hex entities (&#x1F;)
  result = result.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
    final code = int.parse(match.group(1)!, radix: 16);
    return String.fromCharCode(code);
  });

  return result;
}

/// Removes any remaining markdown syntax that wasn't parsed by the AST parser.
String _removeRemainingMarkdownSyntax(String text) {
  String result = text;

  // Remove markdown headings (# ## ### etc.)
  result = result.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');

  // Remove bold/italic markers (**text**, *text*, __text__, _text_)
  result = result.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1'); // Bold
  result = result.replaceAll(RegExp(r'__(.+?)__'), r'$1'); // Bold alternative
  result = result.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1'); // Italic
  result = result.replaceAll(RegExp(r'_([^_]+)_'), r'$1'); // Italic alternative

  // Remove strikethrough (~~text~~)
  result = result.replaceAll(RegExp(r'~~(.+?)~~'), r'$1');

  // Remove inline code (`code`)
  result = result.replaceAll(RegExp(r'`([^`]+)`'), r'$1');

  // Remove code blocks (```code```)
  result = result.replaceAll(RegExp(r'```[\s\S]*?```'), '');

  // Remove links ([text](url))
  result = result.replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1');

  // Remove images (![alt](url))
  result = result.replaceAll(RegExp(r'!\[([^\]]*)\]\([^\)]+\)'), r'$1');

  // Remove horizontal rules (--- or ***)
  result = result.replaceAll(RegExp(r'^[-*]{3,}\s*$', multiLine: true), '');

  // Remove list markers (-, *, +, 1., etc.)
  result = result.replaceAll(RegExp(r'^[\s]*[-*+]\s+', multiLine: true), '');
  result = result.replaceAll(RegExp(r'^[\s]*\d+\.\s+', multiLine: true), '');

  // Remove blockquote markers (>)
  result = result.replaceAll(RegExp(r'^>\s+', multiLine: true), '');

  return result;
}

/// Recursively extracts text content from markdown AST nodes.
void _extractTextFromNodes(List<md.Node> nodes, StringBuffer buffer) {
  for (final node in nodes) {
    if (node is md.Text) {
      // Text node - add directly
      buffer.write(node.text);
    } else if (node is md.Element) {
      // Element node - recursively process children
      if (node.children != null && node.children!.isNotEmpty) {
        _extractTextFromNodes(node.children!, buffer);
      }

      // Add spacing for block elements
      if (_isBlockElement(node)) {
        buffer.write('\n');
      }
    }
  }
}

/// Checks if a markdown element is a block-level element (needs line breaks).
bool _isBlockElement(md.Element element) {
  const blockElements = [
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'p',
    'ul',
    'ol',
    'li',
    'blockquote',
    'pre',
    'code',
    'hr',
    'table',
    'thead',
    'tbody',
    'tr',
    'td',
    'th',
  ];
  return blockElements.contains(element.tag);
}
