import 'package:pdf/widgets.dart' as pw;
import '../models/pdf_footer.dart';

/// Builds the PDF footer widget from [PdfFooter], if any.
class FooterBuilder {
  /// Returns a padded footer text widget, or null when [footer] is null or has no text.
  static pw.Widget? build(PdfFooter? footer) {
    if (footer == null || footer.text == null) return null;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        footer.text!,
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }
}
