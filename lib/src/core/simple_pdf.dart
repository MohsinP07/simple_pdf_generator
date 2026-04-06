import 'package:pdf/widgets.dart' as pw;

import '../models/pdf_header.dart';
import '../models/pdf_table.dart';
import '../models/pdf_footer.dart';
import '../builders/header_builder.dart';
import '../builders/table_builder.dart';
import '../builders/footer_builder.dart';

/// Entry point for creating PDF documents from [PdfHeader], [PdfTable], and
/// optional [PdfFooter].
class SimplePdf {
  /// Builds a multi-page PDF with the given [header], [table], and [footer].
  ///
  /// The returned value is a `pdf` package document; call [pw.Document.save]
  /// to obtain `Uint8List` bytes for writing to a file.
  static Future<pw.Document> generate({
    required PdfHeader header,
    required PdfTable table,
    PdfFooter? footer,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          final widgets = <pw.Widget>[];

          // Header
          widgets.addAll(HeaderBuilder.build(header));

          // Table
          widgets.add(TableBuilder.build(table));

          // Footer
          final footerWidget = FooterBuilder.build(footer);
          if (footerWidget != null) {
            widgets.add(footerWidget);
          }

          return widgets;
        },
      ),
    );

    return pdf;
  }
}
