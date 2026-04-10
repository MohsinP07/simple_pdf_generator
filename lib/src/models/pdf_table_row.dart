import 'pdf_section.dart';
import 'pdf_table.dart';

/// Default horizontal gap between adjacent tables in a [PdfTableRow].
const double kPdfTableRowDefaultHorizontalGap = 8;

/// Default vertical padding above a [PdfTableRow] (inside the section).
const double kPdfTableRowDefaultVerticalPaddingBefore = 12;

/// Default vertical padding below a [PdfTableRow] (inside the section).
const double kPdfTableRowDefaultVerticalPaddingAfter = 12;

/// A horizontal group of [PdfTable]s sharing one row; each column gets equal
/// width (after gaps). Tables keep their own styling and summaries.
///
/// Validation: if the estimated minimum width of any table exceeds its share
/// of the page body width, layout throws
/// `Tables exceed available width in PdfTableRow. Reduce columns or number of tables.`
class PdfTableRow extends PdfSection {
  /// At least one table is required.
  final List<PdfTable> tables;

  /// Space between adjacent tables in PDF points.
  final double horizontalGap;

  /// Extra space above the row (in addition to normal spacing between sections).
  final double verticalPaddingBefore;

  /// Extra space below the row (in addition to normal spacing between sections).
  final double verticalPaddingAfter;

  /// Optional full-width heading shown **above** the horizontal [tables] row
  /// (centered), e.g. `"SUMMARY"` before two side-by-side tables.
  final String? titleAbove;

  /// Optional flex weights for each table column (same length as [tables]).
  /// When null, each table gets equal width. When set, horizontal space is
  /// split in proportion to these positive integers (like [Expanded.flex]).
  final List<int>? columnFlex;

  /// Side-by-side tables; each gets the same width (minus [horizontalGap]s).
  PdfTableRow({
    required List<PdfTable> tables,
    this.horizontalGap = kPdfTableRowDefaultHorizontalGap,
    this.verticalPaddingBefore = kPdfTableRowDefaultVerticalPaddingBefore,
    this.verticalPaddingAfter = kPdfTableRowDefaultVerticalPaddingAfter,
    this.titleAbove,
    this.columnFlex,
  }) : tables = List<PdfTable>.unmodifiable(List<PdfTable>.from(tables)) {
    if (this.tables.isEmpty) {
      throw ArgumentError('PdfTableRow.tables must not be empty');
    }
    if (columnFlex != null) {
      if (columnFlex!.length != this.tables.length) {
        throw ArgumentError(
          'PdfTableRow.columnFlex length must match tables length.',
        );
      }
      if (columnFlex!.any((f) => f <= 0)) {
        throw ArgumentError('PdfTableRow.columnFlex values must be positive.');
      }
    }
    for (final t in this.tables) {
      if (t.startOnNewPage) {
        throw ArgumentError(
          'PdfTableRow cannot contain a PdfTable with startOnNewPage: true.',
        );
      }
    }
  }
}
