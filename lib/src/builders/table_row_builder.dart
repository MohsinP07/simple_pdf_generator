import 'package:pdf/widgets.dart' as pw;

import '../models/pdf_font_family.dart';
import '../models/pdf_table_row.dart';
import 'document_section_widgets.dart';
import 'pdf_table_row_validator.dart';
import 'table_builder.dart';

/// Lays out [PdfTableRow] as a horizontal [pw.Row] with equal-width children.
class TableRowBuilder {
  /// Builds a [PdfTableRow] with equal column widths and strict width validation.
  static pw.Widget build(
    PdfTableRow row,
    pw.Context context, {
    Map<PdfFontFamily, pw.Font>? fonts,
  }) {
    return pw.LayoutBuilder(
      builder: (ctx, constraints) {
        validatePdfTableRowLayout(row, constraints!.maxWidth);
        final children = <pw.Widget>[];
        final n = row.tables.length;
        for (var i = 0; i < n; i++) {
          if (i > 0) {
            children.add(pw.SizedBox(width: row.horizontalGap));
          }
          final t = row.tables[i];
          final flex = row.columnFlex?[i] ?? 1;
          children.add(
            pw.Expanded(
              flex: flex,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  ...buildTableLeadInWidgets(t, ctx),
                  ...TableBuilder.buildSection(t, ctx, fonts: fonts),
                ],
              ),
            ),
          );
        }
        final title = row.titleAbove?.trim();
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (row.verticalPaddingBefore > 0)
              pw.SizedBox(height: row.verticalPaddingBefore),
            if (title != null && title.isNotEmpty) ...[
              pw.Center(
                child: pw.Text(
                  title,
                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                ),
              ),
              pw.SizedBox(height: 8),
            ],
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: children,
            ),
            if (row.verticalPaddingAfter > 0)
              pw.SizedBox(height: row.verticalPaddingAfter),
          ],
        );
      },
    );
  }
}
