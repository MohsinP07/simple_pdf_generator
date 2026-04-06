import 'package:pdf/widgets.dart' as pw;
import '../models/pdf_header.dart';

class HeaderBuilder {
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
        pw.Text(header.subtitle!, style: pw.TextStyle(fontSize: 14)),
      if (header.extra != null)
        pw.Text(header.extra!, style: pw.TextStyle(fontSize: 12)),
      pw.SizedBox(height: 20),
    ];
  }
}