/// Build PDFs from structured data with a small API: [SimplePdf.generate],
/// [SimplePdf.invoice], [PdfHeader], [PdfSection] / [PdfTable] / [PdfTableRow],
/// [PdfTableCell] for text/image cells, and [PdfFooter].
///
/// This package wraps the lower-level [`pdf`](https://pub.dev/packages/pdf)
/// layout widgets into a single flow for reports and exports.
///
/// Page orientation: set `pageLandscape` or `pageFormat` on [SimplePdf.generate].
library simple_pdf_generator;

export 'package:pdf/pdf.dart' show PdfPageFormat;
export 'src/core/simple_pdf.dart';
export 'src/models/invoice_data.dart';
export 'src/models/invoice_item.dart';
export 'src/fonts/simple_pdf_fonts.dart';
export 'src/models/pdf_header.dart';
export 'src/models/pdf_section.dart';
export 'src/models/pdf_table.dart';
export 'src/models/pdf_table_row.dart';
export 'src/models/pdf_table_cell.dart';
export 'src/models/pdf_table_header_style.dart';
export 'src/models/pdf_table_cell_style.dart';
export 'src/models/pdf_font_family.dart';
export 'src/models/pdf_summary_style.dart';
export 'src/models/simple_pdf_color.dart';
export 'src/models/pdf_footer.dart';
export 'src/models/pdf_plain_text_block.dart';
