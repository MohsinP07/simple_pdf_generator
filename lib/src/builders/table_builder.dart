import 'package:pdf/widgets.dart' as pw;
import '../models/pdf_table.dart';

class TableBuilder {
  static pw.Widget build(PdfTable table) {
    final mappedData = table.data.map((item) {
      final row = table.mapper != null ? table.mapper!(item) : item;

      return table.headers.map((header) {
        return row[header]?.toString() ?? '';
      }).toList();
    }).toList();

    // Validation
    for (var row in mappedData) {
      if (row.length != table.headers.length) {
        throw Exception("Header and row length mismatch");
      }
    }

    return pw.Table.fromTextArray(
      headers: table.headers,
      data: mappedData,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.center,
      border: pw.TableBorder.all(width: 0.5),
    );
  }
}
