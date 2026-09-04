import 'package:intl/intl.dart';

/// Centralized error messages — NO hardcoded strings in data sources.
/// Language-aware: returns Arabic or English based on the user's locale
/// (`Intl.locale` is set by flutter_localizations from the device/app locale).
abstract class ErrorMessages {
  static String _tr(String ar, String en) =>
      Intl.getCurrentLocale().toLowerCase().startsWith('ar') ? ar : en;

  static String get unexpectedError =>
      _tr('حدث خطأ غير متوقع', 'An unexpected error occurred');
  static String get companyNotFound =>
      _tr('الشركة غير موجودة', 'Company not found');
  static String get customerNotFound =>
      _tr('العميل غير موجود', 'Customer not found');
  static String get invoiceNotFound =>
      _tr('الفاتورة غير موجودة', 'Invoice not found');
  static String get nameAlreadyExists =>
      _tr('هذا الاسم موجود مسبقاً', 'This name already exists');
  static String get imageAlreadyExists =>
      _tr('الصورة موجودة مسبقاً', 'Image already exists');
  static String get noPermission => _tr(
      'ليس لديك صلاحية تنفيذ هذا الإجراء',
      'You do not have permission to perform this action');
  static String get noCompanySelected =>
      _tr('لم يتم تحديد شركة', 'No company selected');
  static String get invoiceIdNotReceived => _tr(
      'لم يتم استلام معرف الفاتورة من الخادم',
      'Invoice ID not received from the server');
  static String get paymentIdNotReceived => _tr(
      'لم يتم استلام معرف الدفعة من الخادم',
      'Payment ID not received from the server');
  static String get invalidAmount =>
      _tr('يجب أن يكون المبلغ أكبر من 0', 'Amount must be greater than 0');
  static String get paymentExceedsRemaining => _tr(
      'المبلغ يتجاوز المبلغ المتبقي',
      'Payment exceeds the remaining amount');
  static String get invoiceCanceled =>
      _tr('الفاتورة ملغاة', 'Invoice is canceled');
  static String get invoiceFullyPaid =>
      _tr('الفاتورة مدفوعة بالكامل', 'Invoice is fully paid');
  static String get insufficientStock =>
      _tr('المخزون غير كافٍ', 'Insufficient stock');
  static String get duplicateData =>
      _tr('بيانات مكررة', 'Duplicate data');
  static String get customerHasInvoices => _tr(
      'لا يمكن حذف عميل له فواتير',
      'Cannot delete a customer with invoices');
  static String get productHasInvoices => _tr(
      'لا يمكن حذف منتج موجود في فواتير',
      'Cannot delete a product used in invoices');
  static String get enterCustomerName =>
      _tr('يرجى إدخال اسم العميل', 'Please enter the customer name');
  static String get addAtLeastOneProduct => _tr(
      'يرجى إضافة منتج واحد على الأقل',
      'Please add at least one product');
  static String get selectCustomer =>
      _tr('الرجاء اختيار عميل', 'Please select a customer');
  static String get enterValidAmount =>
      _tr('يرجى إدخال مبلغ صحيح', 'Please enter a valid amount');
  static String get selectInvoice =>
      _tr('يرجى اختيار فاتورة', 'Please select an invoice');
  static String get failedToUploadLogo =>
      _tr('تعذر رفع الشعار', 'Failed to upload the logo');
  static String get unauthorized => _tr(
      'غير مصرح — يرجى تسجيل الدخول من جديد',
      'Unauthorized — please sign in again');
  static String get forbidden =>
      _tr('ليس لديك صلاحية للوصول', 'You do not have permission to access');
  static String get notFound =>
      _tr('العنصر المطلوب غير موجود', 'The requested item was not found');
  static String get rateLimited =>
      _tr('طلبات كثيرة جداً — يرجى الانتظار', 'Too many requests — please wait');
  static String get validationFailed =>
      _tr('البيانات المدخلة غير صحيحة', 'The entered data is invalid');
  static String get connectionFailed =>
      _tr('تعذر الاتصال بالخادم', 'Failed to connect to the server');
  static String get unsupportedOperation =>
      _tr('هذه العملية غير مدعومة حالياً', 'This operation is not supported yet');
  static String get fileTooLarge =>
      _tr('الصورة كبيرة جداً — الحد الأقصى 5 ميجابايت', 'Image is too large — max 5MB');
}
