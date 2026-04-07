import 'pdf_font_family.dart';
import 'pdf_table_header_style.dart' show PdfTableHeaderFontWeight;
import 'simple_pdf_color.dart';

// ignore_for_file: public_member_api_docs

class PdfSummaryHeaderStyle {
  final double? fontSize;
  final PdfTableHeaderFontWeight? fontWeight;
  final SimplePdfColor? textColor;
  final SimplePdfColor? backgroundColor;

  const PdfSummaryHeaderStyle({
    this.fontSize,
    this.fontWeight,
    this.textColor,
    this.backgroundColor,
  });
}

class PdfSummaryCellStyle {
  final double? fontSize;
  final PdfTableHeaderFontWeight? fontWeight;

  /// Left column (labels) color.
  final SimplePdfColor? labelColor;

  /// Right column (values) color.
  final SimplePdfColor? valueColor;

  const PdfSummaryCellStyle({
    this.fontSize,
    this.fontWeight,
    this.labelColor,
    this.valueColor,
  });
}

/// Optional styling for a [PdfTable] summary section.
///
/// Unset fields keep the package defaults and do not affect other tables.
class PdfSummaryStyle {
  /// Summary header row style (the small table header inside the summary).
  final PdfSummaryHeaderStyle? headerStyle;

  /// Summary body style (data rows inside the summary).
  final PdfSummaryCellStyle? cellStyle;

  /// Optional subtle background behind the whole summary block (outside the table).
  final SimplePdfColor? backgroundColor;

  /// Controlled font selection (no arbitrary strings).
  final PdfFontFamily? fontFamily;

  const PdfSummaryStyle({
    this.headerStyle,
    this.cellStyle,
    this.backgroundColor,
    this.fontFamily,
  });
}

