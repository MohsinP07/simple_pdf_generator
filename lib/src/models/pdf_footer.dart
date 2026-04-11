/// Optional block rendered below sections (e.g. totals, notes, address).
class PdfFooter {
  /// Primary line (e.g. total); omit when using only [trailingLines].
  final String? text;

  /// Optional extra lines below [text] (same default style), in order.
  ///
  /// Useful for amount-in-words, business address, or legal copy without
  /// cramming everything into [text].
  final List<String>? trailingLines;

  /// Creates a footer with optional [text] and optional [trailingLines].
  PdfFooter({this.text, this.trailingLines});
}
