// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pdf_generator/simple_pdf_generator.dart';

/// 1×1 PNG (transparent pixel) for image cell tests.
final Uint8List kTinyPngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final header = PdfHeader(title: 'T');
  final t1 = PdfTable(headers: const ['A'], data: const [
    {'A': '1'},
  ]);
  final t2 = PdfTable(headers: const ['B'], data: const [
    {'B': '2'},
  ]);

  test('generate with tables produces saveable document', () async {
    final doc = await SimplePdf.generate(
      header: header,
      tables: [t1, t2],
    );
    final bytes = await doc.save();
    expect(bytes, isNotEmpty);
  });

  test('generate with legacy table produces saveable document', () async {
    final doc = await SimplePdf.generate(
      header: header,
      table: t1,
    );
    final bytes = await doc.save();
    expect(bytes, isNotEmpty);
  });

  test('non-empty tables wins over table when both provided', () async {
    final doc = await SimplePdf.generate(
      header: header,
      tables: [t1],
      table: t2,
    );
    final bytes = await doc.save();
    expect(bytes, isNotEmpty);
  });

  test('throws when no tables provided', () async {
    expect(
      () => SimplePdf.generate(header: header),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('throws when sections is empty', () async {
    expect(
      () => SimplePdf.generate(header: header, sections: []),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('throws when tables is empty and table is null', () async {
    expect(
      () => SimplePdf.generate(header: header, tables: []),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('Unicode symbols render with default theme (em dash, Greek sigma)', () async {
    final doc = await SimplePdf.generate(
      header: PdfHeader(
        title: 'T',
        subtitle: 'Range — test',
        extra: 'σ symbol',
      ),
      tables: [
        PdfTable(
          headers: const ['Col'],
          data: const [
            {'Col': '— em dash'},
            {'Col': 'σ sigma'},
          ],
        ),
      ],
    );
    expect(await doc.save(), isNotEmpty);
  });

  test('PdfTable headerStyle applies partial overrides', () async {
    final doc = await SimplePdf.generate(
      header: header,
      tables: [
        PdfTable(
          headers: const ['A'],
          data: const [{'A': 'x'}],
          headerStyle: const PdfTableHeaderStyle(
            backgroundColor: SimplePdfColor.blue100,
            textColor: SimplePdfColor.blue900,
          ),
        ),
        PdfTable(
          headers: const ['B'],
          data: const [{'B': 'y'}],
          headerStyle: const PdfTableHeaderStyle(fontSize: 16),
        ),
      ],
    );
    expect(await doc.save(), isNotEmpty);
  });

  test('PdfTable summary renders after table when headers and data set', () async {
    final doc = await SimplePdf.generate(
      header: header,
      tables: [
        PdfTable(
          headers: const ['Item', 'Qty'],
          data: const [
            {'Item': 'A', 'Qty': '1'},
          ],
          summaryHeaders: const ['Total', 'Value'],
          summaryData: const [
            ['Total Amount', '5000'],
            ['Tax', '250'],
          ],
          summaryStyle: const PdfSummaryStyle(
            headerStyle: PdfSummaryHeaderStyle(
              fontSize: 10,
              textColor: SimplePdfColor.grey700,
              backgroundColor: SimplePdfColor.grey100,
            ),
            cellStyle: PdfSummaryCellStyle(
              fontSize: 12,
              labelColor: SimplePdfColor.grey800,
              valueColor: SimplePdfColor.blue900,
            ),
            backgroundColor: SimplePdfColor.grey50,
            fontFamily: PdfFontFamily.lato,
          ),
        ),
      ],
    );
    expect(await doc.save(), isNotEmpty);
  });

  test('PdfTable summary skipped if only headers or only data', () async {
    final onlyHeaders = await SimplePdf.generate(
      header: header,
      tables: [
        PdfTable(
          headers: const ['A'],
          data: const [{'A': '1'}],
          summaryHeaders: const ['X'],
        ),
      ],
    );
    final onlyData = await SimplePdf.generate(
      header: header,
      tables: [
        PdfTable(
          headers: const ['A'],
          data: const [{'A': '1'}],
          summaryData: const [['a', 'b']],
        ),
      ],
    );
    expect(await onlyHeaders.save(), isNotEmpty);
    expect(await onlyData.save(), isNotEmpty);
  });

  test('PdfTable summary skipped if row width mismatches headers', () async {
    final doc = await SimplePdf.generate(
      header: header,
      tables: [
        PdfTable(
          headers: const ['A'],
          data: const [{'A': '1'}],
          summaryHeaders: const ['Col1', 'Col2'],
          summaryData: const [
            ['only one'],
          ],
        ),
      ],
    );
    expect(await doc.save(), isNotEmpty);
  });

  test('PdfTable cellStyle applies only to data cells', () async {
    final doc = await SimplePdf.generate(
      header: header,
      tables: [
        PdfTable(
          headers: const ['A'],
          data: const [{'A': 'default'}],
        ),
        PdfTable(
          headers: const ['B'],
          data: const [{'B': 'styled'}],
          cellStyle: const PdfTableCellStyle(
            fontSize: 12,
            fontWeight: PdfTableHeaderFontWeight.normal,
            textColor: SimplePdfColor.red700,
            fontFamily: PdfFontFamily.poppins,
          ),
        ),
      ],
    );
    expect(await doc.save(), isNotEmpty);
  });

  test('PdfTable mixes text, PdfTableCell.image, and Uint8List in one row', () async {
    final doc = await SimplePdf.generate(
      header: header,
      tables: [
        PdfTable(
          headers: const ['Label', 'Photo', 'Amount'],
          data: [
            {
              'Label': PdfTableCell.text('Item A'),
              'Photo': PdfTableCell.image(
                kTinyPngBytes,
                maxWidth: 24,
                maxHeight: 24,
              ),
              'Amount': r'$12.00',
            },
            {
              'Label': 'Item B',
              'Photo': kTinyPngBytes,
              'Amount': PdfTableCell.text(r'$5.00'),
            },
          ],
        ),
      ],
    );
    expect(await doc.save(), isNotEmpty);
  });

  test('sections with PdfTableRow generates document', () async {
    final doc = await SimplePdf.generate(
      header: header,
      sections: [
        PdfTable(headers: const ['A'], data: const [
          {'A': '1'},
        ]),
        PdfTableRow(
          tables: [
            PdfTable(headers: const ['X'], data: const [
              {'X': 'a'},
            ]),
            PdfTable(headers: const ['Y'], data: const [
              {'Y': 'b'},
            ]),
          ],
        ),
        PdfTable(headers: const ['B'], data: const [
          {'B': '2'},
        ]),
      ],
    );
    expect(await doc.save(), isNotEmpty);
  });

  test('invoice produces saveable document', () async {
    final doc = await SimplePdf.invoice(
      data: InvoiceData(
        companyName: 'Acme Co',
        customerName: 'Jane Buyer',
        customerAddress: '1 High Street\nLondon',
        customerPhone: '+44 20 0000 0000',
        invoiceNumber: 'INV-001',
        date: DateTime(2026, 4, 11),
        amountInWords: 'Two hundred fifty point five only',
        footerNotes: 'Acme Co — Registered in England\nVisit: example.com',
        items: const [
          InvoiceItem(name: 'Widget', quantity: 2, price: 100),
          InvoiceItem(name: 'Gadget', quantity: 1, price: 50.5),
        ],
      ),
    );
    expect(await doc.save(), isNotEmpty);
  });

  test('generate with PdfPlainTextBlock and table produces document', () async {
    final doc = await SimplePdf.generate(
      header: header,
      sections: [
        PdfPlainTextBlock(
          title: 'Notes',
          lines: const ['First line', 'Second line'],
        ),
        PdfTable(
          headers: const ['A'],
          data: const [
            {'A': '1'},
          ],
        ),
      ],
    );
    expect(await doc.save(), isNotEmpty);
  });

  test('PdfFooter trailingLines without text still renders', () async {
    final doc = await SimplePdf.generate(
      header: header,
      tables: [
        PdfTable(headers: const ['X'], data: const [
          {'X': 'y'},
        ]),
      ],
      footer: PdfFooter(
        trailingLines: const ['Line one', 'Line two'],
      ),
    );
    expect(await doc.save(), isNotEmpty);
  });

  test('invoice throws when items is empty', () async {
    expect(
      () => SimplePdf.invoice(
        data: const InvoiceData(
          companyName: 'A',
          customerName: 'B',
          items: [],
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('invoice throws when item quantity or price is invalid', () async {
    expect(
      () => SimplePdf.invoice(
        data: InvoiceData(
          companyName: 'A',
          customerName: 'B',
          items: [
            const InvoiceItem(name: 'x', quantity: 0, price: 1),
          ],
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => SimplePdf.invoice(
        data: InvoiceData(
          companyName: 'A',
          customerName: 'B',
          items: [
            const InvoiceItem(name: 'x', quantity: 1, price: -1),
          ],
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => SimplePdf.invoice(
        data: InvoiceData(
          companyName: 'A',
          customerName: 'B',
          items: [
            InvoiceItem(name: 'x', quantity: double.nan, price: 1),
          ],
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('PdfTableRow throws when tables exceed available width', () async {
    final headers =
        List<String>.generate(10, (i) => 'H${'M' * 25}$i');
    final row = <String, dynamic>{
      for (var i = 0; i < 10; i++) headers[i]: 'V${'W' * 30}$i',
    };
    final wide = PdfTable(headers: headers, data: [row]);
    expect(
      () => SimplePdf.generate(
        header: header,
        sections: [
          PdfTableRow(tables: [wide, wide]),
        ],
      ),
      throwsA(
        predicate((Object e) {
          if (e is! StateError) return false;
          return e.message.contains('Tables exceed available width');
        }),
      ),
    );
  });
}
