/// Utility to sanitize AI-generated Markdown before rendering.
///
/// - Strips leading/trailing fenced code blocks like ```markdown ... ```
/// - Decodes common HTML entities (&quot;, &amp;, etc.)
/// - Unescapes simple LaTeX markers like \( \) and \times so text is readable
String sanitizeMarkdownForRender(String input) {
  if (input.isEmpty) return '';
  String text = input.trim();

  // Strip surrounding fenced code block if present (```lang\n...\n```)
  final fenceStart = RegExp(r'^```[a-zA-Z0-9_-]*\s*\n');
  final fenceEnd = RegExp(r'\n```\s*$');
  if (fenceStart.hasMatch(text) && fenceEnd.hasMatch(text)) {
    text = text.replaceFirst(fenceStart, '');
    text = text.replaceFirst(fenceEnd, '');
  }

  // Decode common HTML entities manually
  text = text
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ');

  // Unescape simple LaTeX inline wrappers so content reads well
  // e.g., \(8 + 2 \times 3\) -> (8 + 2 × 3)
  text = text
      .replaceAll(r'\(', '(')
      .replaceAll(r'\)', ')')
      .replaceAll(r'\times', '×')
      .replaceAll(r'\cdot', '·');

  // Remove stray $1 artifacts from regex operations if any
  text = text.replaceAll(r'$1', '');

  return text.trim();
}
