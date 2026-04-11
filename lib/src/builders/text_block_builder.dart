import 'package:pdf/widgets.dart' as pw;

import '../models/pdf_plain_text_block.dart';

/// Renders [PdfPlainTextBlock] as simple stacked text (no borders).
class TextBlockBuilder {
  /// Builds widgets for [block] using the document theme.
  static List<pw.Widget> build(PdfPlainTextBlock block, pw.Context context) {
    final base = pw.Theme.of(context).defaultTextStyle;
    final out = <pw.Widget>[];

    final tit = block.title?.trim();
    if (tit != null && tit.isNotEmpty) {
      out.add(
        pw.Text(
          tit,
          style: base.copyWith(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );
      out.add(pw.SizedBox(height: 6));
    }

    for (final raw in block.lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      out.add(
        pw.Text(
          line,
          style: base.copyWith(fontSize: 11),
        ),
      );
      out.add(pw.SizedBox(height: 3));
    }

    if (out.isNotEmpty && out.last is pw.SizedBox) {
      out.removeLast();
    }
    return out;
  }
}
