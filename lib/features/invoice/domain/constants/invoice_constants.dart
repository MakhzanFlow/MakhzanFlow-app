/// Centralized non-hardcoded invoice domain constants.
abstract class InvoiceConstants {
  // Discount types
  static const discountFixed = 'fixed';
  static const discountPercentage = 'percentage';

  // UI payment strategy (not backend method)
  static const paymentFull = 'full';
  static const paymentPartial = 'partial';
  static const paymentDeferred = 'deferred';

  // Backend payment methods
  static const methodCash = 'cash';
  static const methodCard = 'card';
  static const methodBankTransfer = 'bank_transfer';
  static const methodOther = 'other';

  // API defaults
  static const defaultPageSize = 20;
  static const maxPageSize = 100;
}
