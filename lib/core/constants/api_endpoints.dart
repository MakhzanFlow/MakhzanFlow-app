/// Centralized API endpoint constants — NO hardcoded paths in data sources.
abstract class ApiEndpoints {
  static const authBase = '/auth';
  static const login = '$authBase/login';
  static const register = '$authBase/register';
  static const verifyEmail = '$authBase/verify-email';
  static const verifyEmailResend = '$authBase/verify-email/resend';
  static const refresh = '$authBase/refresh';
  static const logout = '$authBase/logout';
  static const me = '$authBase/me';

  static const companiesBase = '/companies';
  static const companies = '$companiesBase/';
  static const companiesPermissions = '$companiesBase/permissions';
  static String companyById(String id) => '$companiesBase/$id';
  static String companyMembers(String id) => '$companiesBase/$id/members';
  static String companyMember(String id, String userId) =>
      '$companiesBase/$id/members/$userId';
  static String companyMemberPermissions(String id, String userId) =>
      '$companiesBase/$id/members/$userId/permissions';
  static const companiesLookup = '$companiesBase/lookup';
  static const companiesJoin = '$companiesBase/join';
  static const companiesMyJoinRequests = '$companiesBase/my-join-requests';
  static String companyJoinRequests(String id) =>
      '$companiesBase/$id/join-requests';
  static String companyJoinRequestAction(String id, String reqId, String action) =>
      '$companiesBase/$id/join-requests/$reqId/$action';
  static String companyInviteCodeRegenerate(String id) =>
      '$companiesBase/$id/invite-code/regenerate';

  static const productsBase = '/products';
  static const products = '$productsBase/';
  static String productById(String id) => '$productsBase/$id';
  static String productImage(String id) => '$productsBase/$id/image';
  static String productActivity(String id) => '$productsBase/$id/activity-logs';

  static const customersBase = '/customers';
  static const customers = '$customersBase/';
  static const customersSummary = '$customersBase/summary';
  static const customersDebtors = '$customersBase/debtors';
  static String customerById(String id) => '$customersBase/$id';
  static String customerImage(String id) => '$customersBase/$id/image';
  static String customerDebt(String id) => '$customersBase/$id/debt';
  static String customerInvoices(String id) => '$customersBase/$id/invoices';
  static String customerPayments(String id) => '$customersBase/$id/payments';

  static const invoicesBase = '/invoices';
  static const invoices = '$invoicesBase/';
  static String invoiceById(String id) => '$invoicesBase/$id';
  static String invoicePayments(String id) => '$invoicesBase/$id/payments';
  static String invoiceCancel(String id) => '$invoicesBase/$id/cancel';

  static const dashboardBase = '/dashboard';
  static const dashboardStats = '$dashboardBase/stats';
  static const dashboardLowStock = '$dashboardBase/low-stock';
  static const dashboardMonthlyReport = '$dashboardBase/monthly-report';
  static const dashboardActivity = '$dashboardBase/activity';
}
