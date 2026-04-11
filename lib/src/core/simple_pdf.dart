import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;

import '../invoice/invoice_pdf_adapter.dart';
import '../invoice/invoice_validator.dart';
import '../models/invoice_data.dart';
import '../models/pdf_header.dart';
import '../models/pdf_plain_text_block.dart';
import '../models/pdf_section.dart';
import '../models/pdf_table.dart';
import '../models/pdf_table_row.dart';
import '../models/pdf_footer.dart';
import '../builders/header_builder.dart';
import '../builders/table_builder.dart';
import '../builders/footer_builder.dart';
import '../builders/text_block_builder.dart';
import '../builders/document_section_widgets.dart';
import '../builders/table_row_builder.dart';
import '../builders/pdf_table_row_validator.dart';
import '../fonts/simple_pdf_fonts.dart';
import '../models/pdf_font_family.dart';

/// Vertical gap between consecutive tables (pdf layout units, ~points).
const double kSimplePdfTableSpacing = 24;

/// Entry point for creating PDF documents from [PdfHeader], one or more
/// [PdfSection]s (or legacy [PdfTable]s), and optional [PdfFooter].
class SimplePdf {
  /// Builds a multi-page PDF with the given [header], [sections] or [tables]
  /// (or legacy [table]), and [footer].
  ///
  /// Prefer [sections] when mixing full-width [PdfTable]s, [PdfPlainTextBlock]
  /// sections, or [PdfTableRow] (side-by-side tables). If [sections] is non-null
  /// and not empty, it is used and [tables] / [table] are ignored.
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
    List<PdfSection>? sections,
    List<PdfTable>? tables,
    @Deprecated('Use tables instead')
    PdfTable? table,
    PdfFooter? footer,
    pw.ThemeData? theme,
    bool pageLandscape = false,
    PdfPageFormat? pageFormat,
  }) async {
    final resolvedSections = _resolveSections(
      sections: sections,
      tables: tables,
      table: table,
    );
    final themeData = theme ?? await loadSimplePdfUnicodeTheme();
    final allTables = _flattenTables(resolvedSections);
    final fonts = await _loadRequiredFonts(allTables);
    final pdf = pw.Document();

    final PdfPageFormat resolvedPageFormat = pageFormat ??
        (pageLandscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4);

    _validateTableRowsAgainstPage(resolvedSections, resolvedPageFormat);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: resolvedPageFormat,
        theme: themeData,
        build: (context) {
          final widgets = <pw.Widget>[];

          widgets.addAll(HeaderBuilder.build(header));

          for (var i = 0; i < resolvedSections.length; i++) {
            final section = resolvedSections[i];
            if (section is PdfTable) {
              if (section.startOnNewPage) {
                widgets.add(pw.NewPage());
              }
              if (i > 0 && !section.startOnNewPage) {
                widgets.add(pw.SizedBox(height: kSimplePdfTableSpacing));
              }
              widgets.addAll(buildTableLeadInWidgets(section, context));
              widgets.addAll(
                TableBuilder.buildSection(
                  section,
                  context,
                  fonts: fonts,
                ),
              );
            } else if (section is PdfPlainTextBlock) {
              if (i > 0) {
                widgets.add(pw.SizedBox(height: kSimplePdfTableSpacing));
              }
              widgets.addAll(TextBlockBuilder.build(section, context));
            } else if (section is PdfTableRow) {
              if (i > 0) {
                widgets.add(pw.SizedBox(height: kSimplePdfTableSpacing));
              }
              widgets.add(
                TableRowBuilder.build(
                  section,
                  context,
                  fonts: fonts,
                ),
              );
            }
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

  /// Builds a minimal invoice PDF from structured [data].
  ///
  /// Uses the same rendering pipeline as [generate]: [PdfHeader], a plain-text
  /// [PdfPlainTextBlock] for “Bill To”, [PdfTable] for line items, and
  /// [PdfFooter] for total plus optional amount-in-words and footer notes.
  /// Throws [ArgumentError]
  /// when validation fails (empty items, empty names, or non-finite / out of
  /// range quantities and prices).
  ///
  /// Optional [theme], [pageLandscape], and [pageFormat] behave like [generate].
  static Future<pw.Document> invoice({
    required InvoiceData data,
    pw.ThemeData? theme,
    bool pageLandscape = false,
    PdfPageFormat? pageFormat,
  }) async {
    InvoiceValidator.validate(data);
    return generate(
      header: InvoicePdfAdapter.buildHeader(data),
      sections: InvoicePdfAdapter.buildSections(data),
      footer: InvoicePdfAdapter.buildFooter(data),
      theme: theme,
      pageLandscape: pageLandscape,
      pageFormat: pageFormat,
    );
  }

  static void _validateTableRowsAgainstPage(
    List<PdfSection> sections,
    PdfPageFormat pageFormat,
  ) {
    final w = pageFormat.availableWidth;
    for (final s in sections) {
      if (s is PdfTableRow) {
        validatePdfTableRowLayout(s, w);
      }
    }
  }

  static List<PdfSection> _resolveSections({
    List<PdfSection>? sections,
    List<PdfTable>? tables,
    PdfTable? table,
  }) {
    if (sections != null) {
      if (sections.isEmpty) {
        throw ArgumentError(
          'sections must not be empty when provided. Omit sections and use tables instead.',
        );
      }
      return List<PdfSection>.from(sections);
    }
    final legacy = _resolveTables(tables: tables, table: table);
    return legacy.map<PdfSection>((t) => t).toList();
  }

  static List<PdfTable> _flattenTables(List<PdfSection> sections) {
    final out = <PdfTable>[];
    for (final s in sections) {
      if (s is PdfTable) {
        out.add(s);
      } else if (s is PdfTableRow) {
        out.addAll(s.tables);
      }
    }
    return out;
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
      'SimplePdf.generate requires at least one table: pass sections, tables, or table.',
    );
  }
}
