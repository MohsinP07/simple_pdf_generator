import 'pdf_section.dart';

/// Borderless text block: optional [title] plus [lines] (paragraph-style layout).
///
/// Use for copy that should not use [PdfTable] chrome (e.g. “Bill To” blocks).
class PdfPlainTextBlock extends PdfSection {
  /// Optional heading shown above [lines] (e.g. `Bill To:`).
  final String? title;

  /// Body lines; each non-empty trimmed line is rendered as its own text line.
  final List<String> lines;

  /// Creates a plain text section with optional [title] and required [lines].
  PdfPlainTextBlock({
    this.title,
    required this.lines,
  });
}
