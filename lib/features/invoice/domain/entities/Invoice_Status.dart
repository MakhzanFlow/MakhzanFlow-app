enum InvoiceStatus { debt, partial, paid, canceled }

extension InvoiceStatusX on InvoiceStatus {
  /// Backend REST status values.
  String get apiValue {
    switch (this) {
      case InvoiceStatus.debt:
        return 'pending';
      case InvoiceStatus.partial:
        return 'partially_paid';
      case InvoiceStatus.paid:
        return 'paid';
      case InvoiceStatus.canceled:
        return 'canceled';
    }
  }

  static InvoiceStatus fromApi(String? raw) {
    switch (raw) {
      case 'pending':
      case 'debt':
        return InvoiceStatus.debt;
      case 'partially_paid':
      case 'partial':
        return InvoiceStatus.partial;
      case 'paid':
        return InvoiceStatus.paid;
      case 'canceled':
        return InvoiceStatus.canceled;
      default:
        return InvoiceStatus.debt;
    }
  }
}
