import '../models/invoice_data.dart';
import '../models/invoice_item.dart';

/// Validates [InvoiceData] before PDF layout (throws [ArgumentError]).
class InvoiceValidator {
  InvoiceValidator._();

  /// Throws [ArgumentError] when [data] cannot be rendered as an invoice.
  static void validate(InvoiceData data) {
    if (data.companyName.trim().isEmpty) {
      throw ArgumentError('companyName must not be empty');
    }
    if (data.customerName.trim().isEmpty) {
      throw ArgumentError('customerName must not be empty');
    }
    if (data.items.isEmpty) {
      throw ArgumentError('items must not be empty');
    }
    for (var i = 0; i < data.items.length; i++) {
      _validateItem(data.items[i], i);
    }
  }

  static void _validateItem(InvoiceItem item, int index) {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('items[$index].name must not be empty');
    }
    if (!_isValidNumber(item.quantity)) {
      throw ArgumentError(
        'items[$index].quantity must be a finite number > 0',
      );
    }
    if (item.quantity <= 0) {
      throw ArgumentError('items[$index].quantity must be > 0');
    }
    if (!_isValidNumber(item.price)) {
      throw ArgumentError(
        'items[$index].price must be a finite number >= 0',
      );
    }
    if (item.price < 0) {
      throw ArgumentError('items[$index].price must be >= 0');
    }
  }

  static bool _isValidNumber(num n) {
    if (n is double) {
      return n.isFinite;
    }
    return true;
  }
}
