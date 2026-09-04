/// Permission keys for the nested JSON permission structure.
/// Keys use dotted-path notation for traversal (e.g. "customers.view").
class PermissionKeys {
  static const String dashboard = 'dashboard';

  static const String customersView = 'customers.view';
  static const String customersCreate = 'customers.create';
  static const String customersEdit = 'customers.edit';
  static const String customersDelete = 'customers.delete';

  static const String productsView = 'products.view';
  static const String productsCreate = 'products.create';
  static const String productsEdit = 'products.edit';
  static const String productsDelete = 'products.delete';

  static const String invoicesView = 'invoices.view';
  static const String invoicesCreate = 'invoices.create';
  static const String invoicesEdit = 'invoices.edit';
  static const String invoicesDelete = 'invoices.delete';
  static const String invoicesCancel = 'invoices.cancel';

  static const String paymentsView = 'payments.view';
  static const String paymentsCreate = 'payments.create';

  static const String reportsView = 'reports.view';
  static const String reportsExport = 'reports.export';

  /// All available dotted-path keys.
  static const List<String> allKeys = [
    dashboard,
    customersView,
    customersCreate,
    customersEdit,
    customersDelete,
    productsView,
    productsCreate,
    productsEdit,
    productsDelete,
    invoicesView,
    invoicesCreate,
    invoicesEdit,
    invoicesDelete,
    invoicesCancel,
    paymentsView,
    paymentsCreate,
    reportsView,
    reportsExport,
  ];
}
