import 'pdf_font_family.dart';
import 'pdf_table_header_style.dart' show PdfTableHeaderFontWeight;
import 'simple_pdf_color.dart';

// ignore_for_file: public_member_api_docs

/// Optional styling for a [PdfTable]'s data cells (non-header rows).
///
/// Unset fields keep the package defaults and do not affect other tables.
class PdfTableCellStyle {
  final double? fontSize;
  final PdfTableHeaderFontWeight? fontWeight;
  final SimplePdfColor? textColor;

  /// Controlled font selection (no arbitrary strings).
  final PdfFontFamily? fontFamily;

  const PdfTableCellStyle({
    this.fontSize,
    this.fontWeight,
    this.textColor,
    this.fontFamily,
  });
}

