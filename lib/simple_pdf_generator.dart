/// Build PDFs from structured data with a small API: [SimplePdf.generate],
/// [PdfHeader], [PdfTable], and [PdfFooter].
///
/// This package wraps the lower-level [`pdf`](https://pub.dev/packages/pdf)
/// layout widgets into a single flow for reports and exports.
library simple_pdf_generator;

export 'src/core/simple_pdf.dart';
export 'src/models/pdf_header.dart';
export 'src/models/pdf_table.dart';
export 'src/models/pdf_footer.dart';
