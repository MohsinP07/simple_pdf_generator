import 'dart:typed_data';

import 'package:flutter/painting.dart' show BoxFit;
import 'package:pdf/pdf.dart' show PdfColor, PdfColors;
import 'package:pdf/widgets.dart' as pw;

import '../models/pdf_table.dart';
import '../models/pdf_table_cell.dart';
import '../models/pdf_table_cell_style.dart';
import '../models/pdf_font_family.dart';
import '../models/pdf_table_header_style.dart';
import '../models/simple_pdf_color.dart';

class _ResolvedTableCell {
  const _ResolvedTableCell({
    required this.text,
    this.imageBytes,
    this.imageMaxWidth,
    this.imageMaxHeight,
    this.imageFit,
  });

  final String text;
  final Uint8List? imageBytes;
  final double? imageMaxWidth;
  final double? imageMaxHeight;
  final BoxFit? imageFit;

  bool get isImage => imageBytes != null;

  factory _ResolvedTableCell.text(String t) => _ResolvedTableCell(text: t);

  factory _ResolvedTableCell.image(
    Uint8List bytes, {
    required double maxWidth,
    required double maxHeight,
    BoxFit? fit,
  }) {
    return _ResolvedTableCell(
      text: '',
      imageBytes: bytes,
      imageMaxWidth: maxWidth,
      imageMaxHeight: maxHeight,
      imageFit: fit,
    );
  }
}

/// Renders [PdfTable] as a `pdf` [pw.Table] from text arrays and optional
/// image cells.
class TableBuilder {
  static const double _kSummarySpacingAfterTable = 20;

  /// Default max image size in PDF points when [Uint8List] or [PdfTableCell.image]
  /// omits explicit bounds.
  static const double _kDefaultImageMaxWidth = 40;
  static const double _kDefaultImageMaxHeight = 40;

  static final PdfColor _defaultHeaderBackground =
      _toPdfColor(SimplePdfColor.grey300);

  /// Main table plus optional summary block (spacing + compact summary table).
  static List<pw.Widget> buildSection(
    PdfTable table,
    pw.Context context, {
    Map<PdfFontFamily, pw.Font>? fonts,
  }) {
    final widgets = <pw.Widget>[build(table, context, fonts: fonts)];
    if (_hasRenderableSummary(table)) {
      widgets.add(pw.SizedBox(height: _kSummarySpacingAfterTable));
      widgets.add(_buildSummaryTable(context, table, fonts: fonts));
    }
    return widgets;
  }

  /// Maps each row (optionally via [PdfTable.mapper]) and builds the table widget.
  ///
  /// Pass [context] from [pw.MultiPage.build] so table cells inherit [pw.Theme]
  /// fonts (Unicode coverage).
  static pw.Widget build(
    PdfTable table,
    pw.Context context, {
    Map<PdfFontFamily, pw.Font>? fonts,
  }) {
    final rawRows = table.data.map((item) {
      final row = table.mapper != null ? table.mapper!(item) : item;
      final map = row as Map<dynamic, dynamic>;
      return table.headers.map((header) => map[header]).toList();
    }).toList();

    for (final row in rawRows) {
      if (row.length != table.headers.length) {
        throw Exception("Header and row length mismatch");
      }
    }

    final resolvedRows =
        rawRows.map((row) => row.map(_resolveCell).toList()).toList();
    final hasImages =
        resolvedRows.any((row) => row.any((cell) => cell.isImage));

    final headerStyle = _resolveHeaderTextStyle(context, table.headerStyle);
    final cellStyle = _resolveCellTextStyle(context, table.cellStyle, fonts);
    final headerCellDecoration = pw.BoxDecoration(
      color: table.headerStyle?.backgroundColor != null
          ? _toPdfColor(table.headerStyle!.backgroundColor!)
          : _defaultHeaderBackground,
    );

    if (!hasImages) {
      final mappedData = resolvedRows
          .map((row) => row.map((c) => c.text).toList())
          .toList();
      return pw.Table.fromTextArray(
        context: context,
        headers: table.headers,
        data: mappedData,
        headerStyle: headerStyle,
        headerCellDecoration: headerCellDecoration,
        cellStyle: cellStyle,
        cellAlignment: pw.Alignment.center,
        border: pw.TableBorder.all(width: 0.5),
      );
    }

    return _buildTableWithMixedCells(
      context,
      headers: table.headers,
      resolvedRows: resolvedRows,
      headerStyle: headerStyle,
      headerCellDecoration: headerCellDecoration,
      cellStyle: cellStyle,
    );
  }

  static _ResolvedTableCell _resolveCell(dynamic raw) {
    if (raw == null) {
      return _ResolvedTableCell.text('');
    }
    if (raw is PdfTableCell) {
      if (raw.isImage) {
        return _ResolvedTableCell.image(
          raw.bytes!,
          maxWidth: raw.maxWidth ?? _kDefaultImageMaxWidth,
          maxHeight: raw.maxHeight ?? _kDefaultImageMaxHeight,
          fit: raw.fit,
        );
      }
      return _ResolvedTableCell.text(raw.text);
    }
    if (raw is Uint8List) {
      return _ResolvedTableCell.image(
        raw,
        maxWidth: _kDefaultImageMaxWidth,
        maxHeight: _kDefaultImageMaxHeight,
        fit: null,
      );
    }
    return _ResolvedTableCell.text(raw.toString());
  }

  static pw.Widget _buildTableWithMixedCells(
    pw.Context context, {
    required List<String> headers,
    required List<List<_ResolvedTableCell>> resolvedRows,
    required pw.TextStyle headerStyle,
    required pw.BoxDecoration headerCellDecoration,
    required pw.TextStyle? cellStyle,
  }) {
    final effectiveCellStyle =
        cellStyle ?? pw.Theme.of(context).tableCell;
    const padding = pw.EdgeInsets.all(5);
    const align = pw.Alignment.center;

    final rows = <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        children: [
          for (final h in headers)
            pw.Container(
              alignment: align,
              padding: padding,
              decoration: headerCellDecoration,
              child: pw.Text(
                h,
                style: headerStyle,
                textAlign: pw.TextAlign.center,
              ),
            ),
        ],
      ),
    ];

    for (final row in resolvedRows) {
      rows.add(
        pw.TableRow(
          children: [
            for (final cell in row)
              pw.Container(
                alignment: align,
                padding: padding,
                child: cell.isImage
                    ? pw.Image(
                        pw.MemoryImage(cell.imageBytes!),
                        width: cell.imageMaxWidth,
                        height: cell.imageMaxHeight,
                        fit: _toPdfBoxFit(cell.imageFit),
                      )
                    : pw.Text(
                        cell.text,
                        style: effectiveCellStyle,
                        textAlign: pw.TextAlign.center,
                      ),
              ),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      tableWidth: pw.TableWidth.max,
      defaultColumnWidth: const pw.IntrinsicColumnWidth(),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.full,
      children: rows,
    );
  }

  static pw.BoxFit _toPdfBoxFit(BoxFit? fit) {
    if (fit == null) return pw.BoxFit.contain;
    switch (fit) {
      case BoxFit.fill:
        return pw.BoxFit.fill;
      case BoxFit.contain:
        return pw.BoxFit.contain;
      case BoxFit.cover:
        return pw.BoxFit.cover;
      case BoxFit.fitWidth:
        return pw.BoxFit.fitWidth;
      case BoxFit.fitHeight:
        return pw.BoxFit.fitHeight;
      case BoxFit.none:
        return pw.BoxFit.none;
      case BoxFit.scaleDown:
        return pw.BoxFit.scaleDown;
    }
  }

  static bool _hasRenderableSummary(PdfTable table) {
    final headers = table.summaryHeaders;
    final data = table.summaryData;
    if (headers == null || data == null) return false;
    if (headers.isEmpty || data.isEmpty) return false;
    final n = headers.length;
    for (final row in data) {
      if (row.length != n) return false;
    }
    return true;
  }

  static pw.Widget _buildSummaryTable(
    pw.Context context,
    PdfTable table, {
    Map<PdfFontFamily, pw.Font>? fonts,
  }) {
    final headers = table.summaryHeaders!;
    final rawData = table.summaryData!;
    final base = pw.Theme.of(context).defaultTextStyle;
    final s = table.summaryStyle;
    final hs = s?.headerStyle;
    final cs = s?.cellStyle;

    final PdfFontFamily? family = s?.fontFamily;
    final resolvedFont = family != null && fonts != null ? fonts[family] : null;

    final double headerFontSize = (hs?.fontSize ?? 10);
    final double cellFontSize = (cs?.fontSize ?? 11);

    pw.FontWeight? headerWeight;
    if (hs?.fontWeight != null) {
      headerWeight = hs!.fontWeight == PdfTableHeaderFontWeight.bold
          ? pw.FontWeight.bold
          : pw.FontWeight.normal;
    }
    pw.FontWeight? cellWeight;
    if (cs?.fontWeight != null) {
      cellWeight = cs!.fontWeight == PdfTableHeaderFontWeight.bold
          ? pw.FontWeight.bold
          : pw.FontWeight.normal;
    }

    // Defaults: labels normal, values slightly bold (visually emphasized).
    final labelStyle = base.copyWith(
      fontSize: cellFontSize,
      fontWeight: cellWeight ?? pw.FontWeight.normal,
      color: cs?.labelColor != null ? _toPdfColor(cs!.labelColor!) : null,
      font: resolvedFont,
      fontNormal: resolvedFont,
      fontBold: resolvedFont,
      fontItalic: resolvedFont,
      fontBoldItalic: resolvedFont,
    );
    final valueStyle = base.copyWith(
      fontSize: cellFontSize,
      fontWeight: cellWeight ?? pw.FontWeight.bold,
      color: cs?.valueColor != null ? _toPdfColor(cs!.valueColor!) : null,
      font: resolvedFont,
      fontNormal: resolvedFont,
      fontBold: resolvedFont,
      fontItalic: resolvedFont,
      fontBoldItalic: resolvedFont,
    );

    final headerStyle = base.copyWith(
      fontSize: headerFontSize,
      fontWeight: headerWeight ?? pw.FontWeight.bold,
      color: hs?.textColor != null
          ? _toPdfColor(hs!.textColor!)
          : PdfColors.black,
      font: resolvedFont,
      fontNormal: resolvedFont,
      fontBold: resolvedFont,
      fontItalic: resolvedFont,
      fontBoldItalic: resolvedFont,
    );

    // Default: match main table border so the summary is clearly boxed.
    final border = pw.TableBorder.all(width: 0.5);

    final rows = <pw.TableRow>[];

    // Header row: slightly highlighted but light.
    rows.add(
      pw.TableRow(
        children: [
          for (final h in headers)
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: pw.BoxDecoration(
                color: hs?.backgroundColor != null
                    ? _toPdfColor(hs!.backgroundColor!)
                    : PdfColors.grey100,
              ),
              child: pw.Text(h, style: headerStyle),
            ),
        ],
      ),
    );

    for (final row in rawData) {
      rows.add(
        pw.TableRow(
          children: [
            for (var i = 0; i < row.length; i++)
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: pw.Text(
                  row[i],
                  style: i == 0 ? labelStyle : (i == 1 ? valueStyle : labelStyle),
                ),
              ),
          ],
        ),
      );
    }

    final summaryTable = pw.Table(
      tableWidth: pw.TableWidth.min,
      border: border,
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: rows,
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'Summary',
          style: base.copyWith(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          decoration: s?.backgroundColor != null
              ? pw.BoxDecoration(color: _toPdfColor(s!.backgroundColor!))
              : null,
          child: pw.Center(child: summaryTable),
        ),
      ],
    );
  }

  /// Matches previous defaults: theme body size + bold. Applies any set fields
  /// from [override] on top.
  static pw.TextStyle _resolveHeaderTextStyle(
    pw.Context context,
    PdfTableHeaderStyle? override,
  ) {
    final base = pw.Theme.of(context).defaultTextStyle.copyWith(
          fontWeight: pw.FontWeight.bold,
        );
    if (override == null) {
      return base;
    }

    pw.FontWeight? weight;
    if (override.fontWeight != null) {
      weight = override.fontWeight == PdfTableHeaderFontWeight.bold
          ? pw.FontWeight.bold
          : pw.FontWeight.normal;
    }

    return base.copyWith(
      color: override.textColor != null
          ? _toPdfColor(override.textColor!)
          : null,
      fontSize: override.fontSize,
      fontWeight: weight,
    );
  }

  static pw.TextStyle? _resolveCellTextStyle(
    pw.Context context,
    PdfTableCellStyle? override,
    Map<PdfFontFamily, pw.Font>? fonts,
  ) {
    if (override == null) return null;

    final base = pw.Theme.of(context).tableCell;

    pw.FontWeight? weight;
    if (override.fontWeight != null) {
      weight = override.fontWeight == PdfTableHeaderFontWeight.bold
          ? pw.FontWeight.bold
          : pw.FontWeight.normal;
    }

    final PdfFontFamily? family = override.fontFamily;
    final resolvedFont = family != null && fonts != null ? fonts[family] : null;

    return base.copyWith(
      color:
          override.textColor != null ? _toPdfColor(override.textColor!) : null,
      fontSize: override.fontSize,
      fontWeight: weight,
      font: resolvedFont,
      fontNormal: resolvedFont,
      fontBold: resolvedFont,
      fontItalic: resolvedFont,
      fontBoldItalic: resolvedFont,
    );
  }

  static PdfColor _toPdfColor(SimplePdfColor c) {
    switch (c) {
      case SimplePdfColor.white:
        return PdfColors.white;
      case SimplePdfColor.black:
        return PdfColors.black;

      case SimplePdfColor.grey50:
        return PdfColors.grey50;
      case SimplePdfColor.grey100:
        return PdfColors.grey100;
      case SimplePdfColor.grey200:
        return PdfColors.grey200;
      case SimplePdfColor.grey300:
        return PdfColors.grey300;
      case SimplePdfColor.grey400:
        return PdfColors.grey400;
      case SimplePdfColor.grey500:
        return PdfColors.grey500;
      case SimplePdfColor.grey600:
        return PdfColors.grey600;
      case SimplePdfColor.grey700:
        return PdfColors.grey700;
      case SimplePdfColor.grey800:
        return PdfColors.grey800;
      case SimplePdfColor.grey900:
        return PdfColors.grey900;

      case SimplePdfColor.blue50:
        return PdfColors.blue50;
      case SimplePdfColor.blue100:
        return PdfColors.blue100;
      case SimplePdfColor.blue200:
        return PdfColors.blue200;
      case SimplePdfColor.blue300:
        return PdfColors.blue300;
      case SimplePdfColor.blue400:
        return PdfColors.blue400;
      case SimplePdfColor.blue500:
        return PdfColors.blue500;
      case SimplePdfColor.blue600:
        return PdfColors.blue600;
      case SimplePdfColor.blue700:
        return PdfColors.blue700;
      case SimplePdfColor.blue800:
        return PdfColors.blue800;
      case SimplePdfColor.blue900:
        return PdfColors.blue900;

      case SimplePdfColor.red100:
        return PdfColors.red100;
      case SimplePdfColor.red500:
        return PdfColors.red500;
      case SimplePdfColor.red700:
        return PdfColors.red700;
      case SimplePdfColor.red900:
        return PdfColors.red900;

      case SimplePdfColor.green100:
        return PdfColors.green100;
      case SimplePdfColor.green500:
        return PdfColors.green500;
      case SimplePdfColor.green700:
        return PdfColors.green700;
      case SimplePdfColor.green900:
        return PdfColors.green900;

      case SimplePdfColor.amber500:
        return PdfColors.amber500;
      case SimplePdfColor.teal500:
        return PdfColors.teal500;
      case SimplePdfColor.indigo500:
        return PdfColors.indigo500;
    }
  }
}
