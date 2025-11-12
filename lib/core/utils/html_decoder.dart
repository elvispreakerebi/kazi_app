/// Decodes HTML entities to their actual characters.
/// 
/// This function converts HTML entities like &quot; to actual quotes,
/// &amp; to &, etc. It also removes any $1 artifacts that might be
/// present from regex replacements.
/// 
/// [text] The text string that may contain HTML entities
/// Returns the text with HTML entities decoded
String decodeHtmlEntities(String text) {
  if (text.isEmpty) {
    return text;
  }

  String result = text;

  // Remove any $1 artifacts first (regex replacement artifacts)
  result = result.replaceAll(RegExp(r'\$1'), '');

  // Common HTML entities
  result = result
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&copy;', '©')
      .replaceAll('&reg;', '®')
      .replaceAll('&trade;', '™');

  // Decode numeric entities (&#123;)
  result = result.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
    try {
      final code = int.parse(match.group(1)!);
      return String.fromCharCode(code);
    } catch (e) {
      return match.group(0)!; // Return original if parsing fails
    }
  });

  // Decode hex entities (&#x1F;)
  result = result.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
    try {
      final code = int.parse(match.group(1)!, radix: 16);
      return String.fromCharCode(code);
    } catch (e) {
      return match.group(0)!; // Return original if parsing fails
    }
  });

  return result;
}

