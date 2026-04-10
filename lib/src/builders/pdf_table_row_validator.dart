import '../models/pdf_table_row.dart';
import 'table_builder.dart';

/// Thrown when tables in a [PdfTableRow] cannot fit in equal-width columns.
const String kPdfTableRowWidthExceededMessage =
    'Tables exceed available width in PdfTableRow. Reduce columns or number of tables.';

/// Validates that each table’s estimated minimum width fits its equal share of
/// [maxRowWidth] (body width, in PDF points), accounting for [horizontal gaps][PdfTableRow.horizontalGap].
void validatePdfTableRowLayout(PdfTableRow row, double maxRowWidth) {
  final n = row.tables.length;
  final gapTotal = (n - 1) * row.horizontalGap;
  final inner = maxRowWidth - gapTotal;
  if (inner <= 0) {
    throw StateError(kPdfTableRowWidthExceededMessage);
  }
  final flexes = row.columnFlex;
  final sumFlex = flexes == null
      ? n
      : flexes.fold<int>(0, (a, b) => a + b);
  for (var i = 0; i < n; i++) {
    final f = flexes?[i] ?? 1;
    final share = inner * f / sumFlex;
    if (TableBuilder.estimateMinSectionWidth(row.tables[i]) > share) {
      throw StateError(kPdfTableRowWidthExceededMessage);
    }
  }
}
