import 'package:makhzanflow/core/constants/app_strings.dart';

/// Maps permission dotted-path keys to their Arabic display labels.
final Map<String, String> permissionLabels = {
  // Dashboard
  'dashboard': AppStrings.permDashboardView,
  // Products
  'products.view': AppStrings.permView,
  'products.create': AppStrings.permCreate,
  'products.edit': AppStrings.permUpdate,
  'products.delete': AppStrings.permDelete,
  // Customers
  'customers.view': AppStrings.permCustomersView,
  'customers.create': AppStrings.permCustomersCreate,
  'customers.edit': AppStrings.permCustomersUpdate,
  'customers.delete': AppStrings.permCustomersDelete,
  // Invoices
  'invoices.view': AppStrings.permInvoicesView,
  'invoices.create': AppStrings.permInvoicesCreate,
  'invoices.edit': AppStrings.permInvoicesUpdate,
  'invoices.delete': AppStrings.permInvoicesDelete,
  // Payments
  'payments.view': AppStrings.permPaymentsView,
  'payments.create': AppStrings.permPaymentsCreate,
  // Reports
  'reports.view': AppStrings.permReportsView,
  'reports.export': AppStrings.permExportExcel,
};

/// Groups permission keys by section for display in the permission editor.
final Map<String, List<String>> permissionSections = {
  AppStrings.sectionDashboard: [
    'dashboard',
  ],
  AppStrings.sectionProducts: [
    'products.view',
    'products.create',
    'products.edit',
    'products.delete',
  ],
  AppStrings.sectionCustomers: [
    'customers.view',
    'customers.create',
    'customers.edit',
    'customers.delete',
  ],
  AppStrings.sectionInvoices: [
    'invoices.view',
    'invoices.create',
    'invoices.edit',
    'invoices.delete',
  ],
  AppStrings.sectionPayments: [
    'payments.view',
    'payments.create',
  ],
  AppStrings.sectionReports: [
    'reports.view',
    'reports.export',
  ],
};
