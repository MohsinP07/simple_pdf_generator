import 'package:pdf/widgets.dart' as pw;
import '../models/pdf_footer.dart';

/// Builds the PDF footer widget from [PdfFooter], if any.
class FooterBuilder {
  /// Returns a padded footer column, or null when [footer] is null or has no
  /// visible content.
  static pw.Widget? build(PdfFooter? footer) {
    if (footer == null) return null;

    final lines = <String>[];
    final head = footer.text?.trim();
    if (head != null && head.isNotEmpty) {
      lines.add(head);
    }
    for (final raw in footer.trailingLines ?? const <String>[]) {
      final s = raw.trim();
      if (s.isNotEmpty) {
        lines.add(s);
      }
    }
    if (lines.isEmpty) return null;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) pw.SizedBox(height: 4),
            pw.Text(
              lines[i],
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}
