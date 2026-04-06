import 'package:pdf/widgets.dart' as pw;
import '../models/pdf_header.dart';

/// Builds title, subtitle, extra, and spacing widgets for [PdfHeader].
class HeaderBuilder {
  /// Lays out [header] as a vertical list of `pdf` [pw.Text] widgets.
  static List<pw.Widget> build(PdfHeader header) {
    return [
      pw.Text(
        header.title,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      if (header.subtitle != null)
        pw.Text(header.subtitle!, style: const pw.TextStyle(fontSize: 14)),
      if (header.extra != null)
        pw.Text(header.extra!, style: const pw.TextStyle(fontSize: 12)),
      pw.SizedBox(height: 20),
    ];
  }
}
