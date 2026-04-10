import 'dart:typed_data';

import 'pdf_section.dart';
import 'pdf_table_cell.dart';
import 'pdf_table_header_style.dart';
import 'pdf_table_cell_style.dart';
import 'pdf_summary_style.dart';

/// Converts each row from [PdfTable.data] into a map whose keys match
/// [PdfTable.headers].
///
/// **Cell values (canonical):** use [PdfTableCell.text] / [PdfTableCell.image]
/// for clarity. These types are also accepted:
/// - [String] — same as [PdfTableCell.text] (Unicode via the document theme)
/// - [num] — converted with [Object.toString]
/// - [Uint8List] — treated as image bytes with default max width/height
/// - [PdfTableCell] — text or image as configured
typedef PdfMapper = Map<String, dynamic> Function(dynamic item);

/// Table layout: column headers and row data, with optional per-row mapping.
class PdfTable extends PdfSection {
  /// Column titles in left-to-right order; keys in each row map should match
  /// these strings (possibly via [mapper]).
  final List<String> headers;

  /// One entry per table row. Use [Map] values whose keys match [headers], or
  /// supply [mapper] to build those maps from your own model type.
  ///
  /// Map values may be strings, [PdfTableCell], or [Uint8List] image bytes; see
  /// [PdfMapper].
  final List<dynamic> data;

  /// When set, each row item is passed through this to produce the cell map.
  final PdfMapper? mapper;

  /// Optional look for the table’s column header row only.
  final PdfTableHeaderStyle? headerStyle;

  /// Optional styling for non-header (data) cells.
  final PdfTableCellStyle? cellStyle;

  /// Optional summary column titles. Must be used with [summaryData]; if either
  /// is missing, no summary is rendered.
  final List<String>? summaryHeaders;

  /// Optional summary rows (each row length must match [summaryHeaders]).
  /// Must be used with [summaryHeaders]; if either is missing, no summary is rendered.
  final List<List<String>>? summaryData;

  /// Optional styling for the summary section only.
  final PdfSummaryStyle? summaryStyle;

  /// Optional plain-text heading shown directly above this table.
  final String? sectionTitle;

  /// Optional image shown above this table (for non-Latin section content).
  final Uint8List? sectionTitleImage;

  /// When true, this table starts on a fresh page.
  final bool startOnNewPage;

  /// Creates a table definition with [headers], [data], and optional [mapper].
  PdfTable({
    required this.headers,
    required this.data,
    this.mapper,
    this.headerStyle,
    this.cellStyle,
    this.summaryHeaders,
    this.summaryData,
    this.summaryStyle,
    this.sectionTitle,
    this.sectionTitleImage,
    this.startOnNewPage = false,
  });
}
