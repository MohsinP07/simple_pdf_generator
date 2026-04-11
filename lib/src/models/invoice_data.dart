import 'invoice_item.dart';

/// Structured input for [SimplePdf.invoice].
class InvoiceData {
  /// Issuer / seller name shown on the invoice.
  final String companyName;

  /// Customer name for the "Bill To" block.
  final String customerName;

  /// Optional customer address (shown under the name when set).
  final String? customerAddress;

  /// Optional customer phone (shown when set).
  final String? customerPhone;

  /// Line items (must not be empty; each item is validated separately).
  final List<InvoiceItem> items;

  /// Optional invoice reference number.
  final String? invoiceNumber;

  /// Optional invoice date.
  final DateTime? date;

  /// Optional amount spelled out; shown below the total when set.
  final String? amountInWords;

  /// Optional footer copy (locations, tagline, etc.). Use `\n` for multiple lines.
  final String? footerNotes;

  /// Creates invoice data with required fields and optional metadata.
  const InvoiceData({
    required this.companyName,
    required this.customerName,
    required this.items,
    this.customerAddress,
    this.customerPhone,
    this.invoiceNumber,
    this.date,
    this.amountInWords,
    this.footerNotes,
  });
}
