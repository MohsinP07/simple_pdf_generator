import 'package:pdf/widgets.dart' as pw;
import '../models/pdf_footer.dart';

class FooterBuilder {
  static pw.Widget? build(PdfFooter? footer) {
    if (footer == null || footer.text == null) return null;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        footer.text!,
        style: pw.TextStyle(fontSize: 10),
      ),
    );
  }
}