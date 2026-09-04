class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String customers = '/customers';
  static const String invoices = '/invoices';
  static const String settings = '/settings';

  static const String productNew = '/products/new';
  static const String productDetails = '/products/:id';
  static const String productEdit = '/products/:id/edit';

  static const String customerNew = '/customers/add';
  static const String customerDetails = '/customers/:id';
  static const String customerEdit = '/customers/:id/edit';

  static const String invoiceCreate = '/invoices/create';
  static const String invoiceDetails = '/invoices/:id';
  static const String customerAddPayment = '/customers/:id/payment';
  static const String customerInvoices = '/customers/:id/invoices';

  static String customerDetailsPath(String id) => '/customers/$id';
  static String customerEditPath(String id) => '/customers/$id/edit';
  static String customerAddPaymentPath(String id) => '/customers/$id/payment';
  static String customerInvoicesPath(String id) => '/customers/$id/invoices';
  static String productDetailsPath(String id) => '/products/$id';
  static String invoiceDetailsPath(String id) => '/invoices/$id';

  static const String companySelect = '/company-select';
  static const String companyCreate = '/company-create';
  static const String companySettings = '/company-settings';
  static const String members = '/members';
  // Onboarding / Welcome routes
  static const String welcome = '/welcome';
  static const String welcomeCreate = '/welcome/create';
  static const String welcomeJoin = '/welcome/join';
  static const String welcomePending = '/welcome/pending';

  // Auth routes
  static const String emailVerification = '/email-verification';

  // Onboarding
  static const String onboardingLanguage = '/onboarding/language';

  static const List<String> shellRoutes = [
    dashboard,
    products,
    customers,
    invoices,
    settings,
  ];
}
