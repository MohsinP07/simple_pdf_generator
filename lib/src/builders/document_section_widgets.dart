import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../models/pdf_table.dart';

/// Widgets shown above a [PdfTable] body (optional image + title).
List<pw.Widget> buildTableLeadInWidgets(
  PdfTable table,
  pw.Context context,
) {
  final out = <pw.Widget>[];
  final Uint8List? img = table.sectionTitleImage;
  if (img != null) {
    out.add(
      pw.Image(
        pw.MemoryImage(img),
        height: 30,
        fit: pw.BoxFit.contain,
      ),
    );
    out.add(pw.SizedBox(height: 6));
  }
  final title = table.sectionTitle;
  if (title != null && title.trim().isNotEmpty) {
    out.add(
      pw.Text(
        title,
        style: pw.Theme.of(context)
            .defaultTextStyle
            .copyWith(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
    );
    out.add(pw.SizedBox(height: 8));
  }
  return out;
}
