import 'pdf_table_header_style.dart';
import 'pdf_table_cell_style.dart';
import 'pdf_summary_style.dart';

/// Converts each row from [PdfTable.data] into a map whose keys match
/// [PdfTable.headers].
typedef PdfMapper = Map<String, dynamic> Function(dynamic item);

/// Table layout: column headers and row data, with optional per-row mapping.
class PdfTable {
  /// Column titles in left-to-right order; keys in each row map should match
  /// these strings (possibly via [mapper]).
  final List<String> headers;

  /// One entry per table row. Use [Map] values whose keys match [headers], or
  /// supply [mapper] to build those maps from your own model type.
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
  });
}
