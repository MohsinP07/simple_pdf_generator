import 'simple_pdf_color.dart';

/// Weight for table header text when using [PdfTableHeaderStyle].
enum PdfTableHeaderFontWeight {
  /// Regular (non-bold) header labels.
  normal,

  /// Bold header labels.
  bold,
}

/// Optional styling for a [PdfTable] header row only (not the document
/// [PdfHeader]).
///
/// Unset fields keep the package defaults: light grey background, bold header
/// text, and theme-based font size.
class PdfTableHeaderStyle {
  /// Cell background behind each header label.
  final SimplePdfColor? backgroundColor;

  /// Header text size in PDF layout units (points).
  final double? fontSize;

  /// When null, headers stay **bold** (package default).
  final PdfTableHeaderFontWeight? fontWeight;

  /// Foreground color for header labels.
  final SimplePdfColor? textColor;

  /// All-null means “use package defaults” when passed from [PdfTable.headerStyle].
  const PdfTableHeaderStyle({
    this.backgroundColor,
    this.fontSize,
    this.fontWeight,
    this.textColor,
  });
}
