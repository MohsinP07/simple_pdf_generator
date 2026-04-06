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

  /// Creates a table definition with [headers], [data], and optional [mapper].
  PdfTable({
    required this.headers,
    required this.data,
    this.mapper,
  });
}
