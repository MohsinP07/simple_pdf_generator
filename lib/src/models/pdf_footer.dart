/// Optional block rendered below the table (e.g. attribution or disclaimer).
class PdfFooter {
  /// Single line of footer text; omit or pass null for no footer.
  final String? text;

  /// Creates a footer with optional [text].
  PdfFooter({this.text});
}
