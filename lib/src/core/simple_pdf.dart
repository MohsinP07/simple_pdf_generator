import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;

import '../models/pdf_header.dart';
import '../models/pdf_table.dart';
import '../models/pdf_footer.dart';
import '../builders/header_builder.dart';
import '../builders/table_builder.dart';
import '../builders/footer_builder.dart';
import '../fonts/simple_pdf_fonts.dart';
import '../models/pdf_font_family.dart';

/// Vertical gap between consecutive tables (pdf layout units, ~points).
const double kSimplePdfTableSpacing = 24;

/// Entry point for creating PDF documents from [PdfHeader], one or more
/// [PdfTable]s, and optional [PdfFooter].
class SimplePdf {
  /// Builds a multi-page PDF with the given [header], [tables] (or legacy
  /// [table]), and [footer].
  ///
  /// Tables are rendered top to bottom in order, separated by
  /// [kSimplePdfTableSpacing]. Each [PdfTable] may append an optional summary
  /// (see [PdfTable.summaryHeaders] / [PdfTable.summaryData]) directly under
  /// that table. The document [PdfHeader] is built once at the start.
  ///
  /// By default a bundled Noto Sans theme is loaded so Unicode characters
  /// (e.g. em dash, Greek letters) render correctly. Override with [theme] if
  /// you supply your own fonts.
  ///
  /// The returned value is a `pdf` package document; call [pw.Document.save]
  /// to obtain `Uint8List` bytes for writing to a file.
  ///
  /// [pageLandscape] uses A4 landscape when true; A4 portrait when false (default).
  /// When [pageFormat] is non-null, it wins over [pageLandscape] (for custom sizes/margins).
  static Future<pw.Document> generate({
    required PdfHeader header,
    List<PdfTable>? tables,
    @Deprecated('Use tables instead')
    PdfTable? table,
    PdfFooter? footer,
    pw.ThemeData? theme,
    bool pageLandscape = false,
    PdfPageFormat? pageFormat,
  }) async {
    final resolvedTables = _resolveTables(tables: tables, table: table);
    final themeData = theme ?? await loadSimplePdfUnicodeTheme();
    final fonts = await _loadRequiredFonts(resolvedTables);
    final pdf = pw.Document();

    final PdfPageFormat resolvedPageFormat = pageFormat ??
        (pageLandscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: resolvedPageFormat,
        theme: themeData,
        build: (context) {
          final widgets = <pw.Widget>[];

          widgets.addAll(HeaderBuilder.build(header));

          for (var i = 0; i < resolvedTables.length; i++) {
            if (resolvedTables[i].startOnNewPage) {
              widgets.add(pw.NewPage());
            }
            if (i > 0 && !resolvedTables[i].startOnNewPage) {
              widgets.add(pw.SizedBox(height: kSimplePdfTableSpacing));
            }
            final sectionTitleImage = resolvedTables[i].sectionTitleImage;
            if (sectionTitleImage != null) {
              widgets.add(
                pw.Image(
                  pw.MemoryImage(sectionTitleImage),
                  height: 30,
                  fit: pw.BoxFit.contain,
                ),
              );
              widgets.add(pw.SizedBox(height: 6));
            }
            final sectionTitle = resolvedTables[i].sectionTitle;
            if (sectionTitle != null && sectionTitle.trim().isNotEmpty) {
              widgets.add(
                pw.Text(
                  sectionTitle,
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              );
              widgets.add(pw.SizedBox(height: 8));
            }
            widgets.addAll(
              TableBuilder.buildSection(
                resolvedTables[i],
                context,
                fonts: fonts,
              ),
            );
          }

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

  static Future<Map<PdfFontFamily, pw.Font>> _loadRequiredFonts(
    List<PdfTable> tables,
  ) async {
    final families = <PdfFontFamily>{};
    for (final t in tables) {
      final ff = t.cellStyle?.fontFamily;
      if (ff != null) families.add(ff);
      final sf = t.summaryStyle?.fontFamily;
      if (sf != null) families.add(sf);
    }
    final out = <PdfFontFamily, pw.Font>{};
    for (final f in families) {
      out[f] = await loadSimplePdfFont(f);
    }
    return out;
  }

  /// Prefers a non-empty [tables] list; otherwise uses [table] as a
  /// single-element list for backward compatibility.
  static List<PdfTable> _resolveTables({
    List<PdfTable>? tables,
    PdfTable? table,
  }) {
    if (tables != null && tables.isNotEmpty) {
      return List<PdfTable>.from(tables);
    }
    if (table != null) {
      return [table];
    }
    if (tables != null && tables.isEmpty) {
      throw ArgumentError(
        'tables must not be empty. Pass at least one PdfTable, or use table.',
      );
    }
    throw ArgumentError(
      'SimplePdf.generate requires at least one table: pass tables or table.',
    );
  }
}
