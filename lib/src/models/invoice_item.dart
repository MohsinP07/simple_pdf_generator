/// One line on an invoice: product name, quantity, unit price, and derived amount.
class InvoiceItem {
  /// Display name or description of the line item.
  final String name;

  /// Quantity sold (must be a finite number > 0).
  final num quantity;

  /// Unit price before line total (must be finite and >= 0).
  final num price;

  /// Creates an invoice line with [name], [quantity], and [price].
  const InvoiceItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}
