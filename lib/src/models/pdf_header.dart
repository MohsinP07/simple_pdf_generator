/// Top-of-page block: main title plus optional subtitle and extra line.
class PdfHeader {
  /// Primary heading (e.g. organization or document name).
  final String title;

  /// Optional second line (e.g. report title).
  final String? subtitle;

  /// Optional third line (e.g. date range or reference).
  final String? extra;

  /// Creates a header with [title] and optional [subtitle] and [extra].
  PdfHeader({
    required this.title,
    this.subtitle,
    this.extra,
  });
}
