import '../models/invoice_data.dart';
import '../models/invoice_item.dart';
import '../models/pdf_footer.dart';
import '../models/pdf_header.dart';
import '../models/pdf_plain_text_block.dart';
import '../models/pdf_section.dart';
import '../models/pdf_table.dart';

/// Maps [InvoiceData] into the package’s header / tables / footer models.
///
/// Keeps invoice-specific composition in one place so future fields (logo, tax,
/// discounts) can extend this layer without touching [SimplePdf.generate].
class InvoicePdfAdapter {
  InvoicePdfAdapter._();

  static const _kDescription = 'Description';
  static const _kQuantity = 'Quantity';
  static const _kPrice = 'Price';
  static const _kAmount = 'Amount';

  /// Header: bold two-line title (`INVOICE` then company), optional number/date in [extra].
  static PdfHeader buildHeader(InvoiceData data) {
    final extraLines = <String>[];
    final inv = data.invoiceNumber?.trim();
    if (inv != null && inv.isNotEmpty) {
      extraLines.add('Invoice #: $inv');
    }
    if (data.date != null) {
      extraLines.add('Date: ${_formatDate(data.date!)}');
    }
    // [PdfHeader.title] is rendered bold; stack INVOICE then company on two lines.
    return PdfHeader(
      title: 'INVOICE\n${data.companyName.trim()}',
      extra: extraLines.isEmpty ? null : extraLines.join('\n'),
    );
  }

  /// Bill-to as plain text, then line-items [PdfTable] (totals / notes in footer).
  static List<PdfSection> buildSections(InvoiceData data) {
    return [
      _buildBillToBlock(data),
      PdfTable(
        headers: const [_kDescription, _kQuantity, _kPrice, _kAmount],
        data: data.items.map(_rowForItem).toList(),
      ),
    ];
  }

  static PdfPlainTextBlock _buildBillToBlock(InvoiceData data) {
    final lines = <String>[data.customerName.trim()];
    final addr = data.customerAddress?.trim();
    if (addr != null && addr.isNotEmpty) {
      for (final part in addr.split(RegExp(r'\r?\n'))) {
        final t = part.trim();
        if (t.isNotEmpty) {
          lines.add(t);
        }
      }
    }
    final phone = data.customerPhone?.trim();
    if (phone != null && phone.isNotEmpty) {
      lines.add(phone);
    }
    return PdfPlainTextBlock(
      title: 'Bill To:',
      lines: lines,
    );
  }

  /// Total, optional amount in words, optional business footer lines.
  static PdfFooter buildFooter(InvoiceData data) {
    final total = data.items.fold<num>(
      0,
      (sum, item) => sum + item.quantity * item.price,
    );
    final trailing = <String>[];

    final words = data.amountInWords?.trim();
    if (words != null && words.isNotEmpty) {
      trailing.add('Amount in words: $words');
    }

    final notes = data.footerNotes?.trim();
    if (notes != null && notes.isNotEmpty) {
      for (final line in notes.split(RegExp(r'\r?\n'))) {
        final t = line.trim();
        if (t.isNotEmpty) {
          trailing.add(t);
        }
      }
    }

    return PdfFooter(
      text: 'Total: ${total.toString()}',
      trailingLines: trailing.isEmpty ? null : trailing,
    );
  }

  static Map<String, String> _rowForItem(InvoiceItem item) {
    final amount = item.quantity * item.price;
    return {
      _kDescription: item.name.trim(),
      _kQuantity: item.quantity.toString(),
      _kPrice: item.price.toString(),
      _kAmount: amount.toString(),
    };
  }

  static String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
