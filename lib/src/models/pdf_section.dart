/// Base type for top-level document sections passed to [SimplePdf.generate].
///
/// Use [PdfTable] for a full-width table, [PdfPlainTextBlock] for simple stacked
/// text without table borders, or [PdfTableRow] to place several [PdfTable]s
/// side by side on one line.
abstract class PdfSection {}
