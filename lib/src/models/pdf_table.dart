typedef PdfMapper = Map<String, dynamic> Function(dynamic item);

class PdfTable {
  final List<String> headers;
  final List data;
  final PdfMapper? mapper;

  PdfTable({
    required this.headers,
    required this.data,
    this.mapper,
  });
}
