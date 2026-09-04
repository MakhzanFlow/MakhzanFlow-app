import 'package:flutter/material.dart';

/// Centralized app strings — bilingual (Arabic + English).
/// Language-aware: returns Arabic or English based on the current locale.
/// All screen text must use [AppStrings] — no hardcoded strings.
///
/// Setup:
///   In main.dart, connect the AppLocaleCubit to AppStrings:
///     context.read<AppLocaleCubit>().stream
///         .forEach((state) => AppStrings.setLocale(state.locale));
///
/// Usage:
///   Text(AppStrings.loginTitle)
///   Text(AppStrings.permissionsTitle(userName))
class AppStrings {
  static Locale _locale = const Locale('ar', 'EG');

  /// Call this when the app language changes. Typically wired to the
  /// [AppLocaleCubit] stream in main.dart.
  static void setLocale(Locale locale) {
    _locale = locale;
  }

  /// Whether the current locale is Arabic (RTL).
  static bool get isArabic => _locale.languageCode == 'ar';

  static String _tr(String ar, String en) =>
      _locale.languageCode == 'ar' ? ar : en;

  // ── Brand / Non-translatable ──────────────────────────────────────────
  static const String appName = 'MakhzanFlow';
  static const String appNameArabic = 'ستوك فلو';
  static const String appVersion = 'الإصدار 1.0.0';
  static const String currencyEg = 'ج.م';
  static const String defaultInitial = 'م';
  static const String defaultAvatarLetter = 'M';
  static const String googleLogoLetter = 'G';
  static const String defaultUserName = 'User';
  static const String barcodeRef = 'INV';
  static const String inviteCodeHint = 'XXXXXX';

  // ── General ───────────────────────────────────────────────────────────
  static String get appSubtitle => _tr('نظام إدارة المخازن الذكي', 'Smart Warehouse Management System');
  static String get loading => _tr('جاري التحميل...', 'Loading...');

  // ── Auth — Login ──────────────────────────────────────────────────────
  static String get loginTitle => _tr('تسجيل الدخول', 'Login');
  static String get loginSubtitle => _tr('تسجيل الدخول', 'Login');
  static String get welcomeBack => _tr('أهلاً بك مجدداً', 'Welcome Back');
  static String get loginToContinue => _tr('سجل دخولك للمتابعة إلى MakhzanFlow', 'Sign in to continue to MakhzanFlow');

  static String get emailLabel => _tr('البريد الإلكتروني', 'Email');
  static String get emailHint => _tr('ahmed@MakhzanFlow.eg', 'ahmed@MakhzanFlow.eg');
  static String get passwordLabel => _tr('كلمة المرور', 'Password');
  static String get passwordHint => _tr('••••••••', '••••••••');

  static String get rememberMe => _tr('تذكرني', 'Remember me');
  static String get forgotPassword => _tr('نسيت كلمة المرور؟', 'Forgot password?');
  static String get loginButton => _tr('تسجيل الدخول', 'Sign In');
  static String get dontHaveAccount => _tr('ليس لديك حساب؟ ', "Don't have an account? ");
  static String get registerNow => _tr('سجل الآن', 'Register now');

  static String get emailRequired => _tr('يرجى إدخال البريد الإلكتروني', 'Please enter your email');
  static String get emailInvalid => _tr('البريد الإلكتروني غير صالح', 'Invalid email address');
  static String get passwordRequired => _tr('يرجى إدخال كلمة المرور', 'Please enter your password');
  static String get passwordMinLength => _tr('كلمة المرور يجب أن تكون 6 أحرف على الأقل', 'Password must be at least 6 characters');

  static String get userDataNotFound => _tr('بيانات المستخدم غير موجودة', 'User data not found');
  static const String unexpectedError = 'حدث خطأ غير متوقع';
  static String get nameLabel => _tr('الاسم', 'Name');
  static String get nameHint => _tr('أحمد محمد', 'Ahmed Mohamed');
  static String get nameRequired => _tr('يرجى إدخال الاسم', 'Please enter your name');
  static String get confirmPasswordLabel => _tr('تأكيد كلمة المرور', 'Confirm Password');
  static String get confirmPasswordHint => _tr('••••••••', '••••••••');
  static String get passwordMismatch => _tr('كلمة المرور غير متطابقة', 'Passwords do not match');

  // ── Auth — Register ───────────────────────────────────────────────────
  static String get registerTitle => _tr('إنشاء حساب', 'Create Account');
  static String get registerWelcome => _tr('انضم إلينا', 'Join Us');
  static String get registerToContinue => _tr('أنشئ حساباً جديداً للمتابعة إلى MakhzanFlow', 'Create a new account to continue to MakhzanFlow');
  static String get registerButton => _tr('إنشاء حساب', 'Create Account');
  static String get alreadyHaveAccount => _tr('لديك حساب بالفعل؟ ', 'Already have an account? ');
  static String get loginNow => _tr('سجل دخول', 'Sign in');

  // ── Auth — Google ─────────────────────────────────────────────────────
  static String get signInWithGoogle => _tr('تسجيل الدخول باستخدام Google', 'Sign in with Google');
  static String get signUpWithGoogle => _tr('التسجيل باستخدام Google', 'Sign up with Google');
  static String get orContinueWith => _tr('أو', 'or');
  static String get googleSignInCancelled => _tr('تم إلغاء تسجيل الدخول', 'Sign-in cancelled');
  static String get googleSignInError => _tr('حدث خطأ أثناء تسجيل الدخول باستخدام Google', 'Error signing in with Google');

  // ── Shell & Navigation ────────────────────────────────────────────────
  static String get navDashboard => _tr('الرئيسية', 'Home');
  static String get navProducts => _tr('المنتجات', 'Products');
  static String get navCustomers => _tr('العملاء', 'Customers');
  static String get navInvoices => _tr('فاتورة', 'Invoices');
  static String get navSettings => _tr('الإعدادات', 'Settings');
  static String get searchHint => _tr('بحث في المنتجات والعملاء والفواتير...', 'Search products, customers, invoices...');
  static String get searchProductsTab => _tr('المنتجات', 'Products');
  static String get searchCustomersTab => _tr('العملاء', 'Customers');
  static String get searchInvoicesTab => _tr('الفواتير', 'Invoices');
  static String get searchTitle => _tr('بحث', 'Search');
  static String get searchStart => _tr('ابدأ بكتابة كلمات للبحث', 'Start typing to search');
  static String get searchEmpty => _tr('لا توجد نتائج', 'No results found');
  static String get searchError => _tr('حدث خطأ أثناء البحث', 'An error occurred while searching');
  static String get actionComingSoon => _tr('قيد الإعداد', 'Coming Soon');

  // ── Company & Multi-Tenant ────────────────────────────────────────────
  static String get selectCompany => _tr('اختر الشركة', 'Select Company');
  static String get selectCompanySubtitle => _tr('اختر الشركة التي تريد العمل بها', 'Choose the company you want to work with');
  static String get createNewCompany => _tr('إنشاء شركة جديدة', 'Create New Company');
  static String get createCompany => _tr('إنشاء شركة', 'Create Company');
  static String get createCompanyButton => _tr('إنشاء الشركة', 'Create Company');

  // ── Create Business Screen ────────────────────────────────────────────
  static String get createBusinessSubtitle => _tr('أدخل بيانات نشاطك التجاري', 'Enter your business details');
  static String get businessNameLabel => _tr('اسم النشاط التجاري', 'Business Name');
  static String get businessNameHint => _tr('مثال: مخزن أحمد للجملة', 'e.g. Ahmed Wholesale Store');
  static String get businessTypeLabel => _tr('نوع النشاط التجاري', 'Business Type');
  static String get createBusinessButton => _tr('إنشاء العمل', 'Create Business');
  static String get cancelButton => _tr('إلغاء', 'Cancel');
  static String get logoPickerLabel => _tr('شعار النشاط', 'Business Logo');
  static String get businessNameRequired => _tr('يرجى إدخال اسم النشاط التجاري', 'Please enter the business name');
  static String get uploadLogoError => _tr('فشل رفع الشعار', 'Failed to upload logo');
  static String get pickFromGallery => _tr('المعرض', 'Gallery');
  static String get pickFromCamera => _tr('الكاميرا', 'Camera');

  // Business types
  static String get businessTypeWholesale => _tr('تجارة الجملة', 'Wholesale');
  static String get businessTypeRetail => _tr('تجزئة', 'Retail');
  static String get businessTypePharmacy => _tr('صيدلية', 'Pharmacy');
  static String get businessTypeSupermarket => _tr('سوبر ماركت', 'Supermarket');
  static String get businessTypeRestaurant => _tr('مطعم', 'Restaurant');
  static String get businessTypeOther => _tr('أخرى', 'Other');

  static String get companyName => _tr('اسم الشركة', 'Company Name');
  static String get companyNameHint => _tr('أدخل اسم الشركة', 'Enter company name');
  static String get companyNameRequired => _tr('يرجى إدخال اسم الشركة', 'Please enter the company name');
  static String get address => _tr('العنوان', 'Address');
  static String get addressHint => _tr('أدخل عنوان الشركة', 'Enter company address');
  static String get phone => _tr('رقم الهاتف', 'Phone Number');
  static String get phoneHint => _tr('أدخل رقم الهاتف', 'Enter phone number');
  static String get companySettings => _tr('إعدادات الشركة', 'Company Settings');
  static String get editCompanyData => _tr('تعديل بيانات شركتك', 'Edit your company details');
  static String get subscriptionPlan => _tr('الخطة', 'Plan');
  static String get status => _tr('الحالة', 'Status');
  static String get save => _tr('حفظ', 'Save');
  static String get retry => _tr('إعادة المحاولة', 'Retry');
  static String get companyUpdated => _tr('تم تحديث الشركة بنجاح', 'Company updated successfully');
  static String get teamMembers => _tr('فريق العمل', 'Team Members');
  static String get noMembersYet => _tr('لا يوجد أعضاء بعد', 'No members yet');
  static String get joinRequests => _tr('طلبات الانضمام', 'Join Requests');
  static String get noJoinRequests => _tr('لا توجد طلبات انضمام', 'No join requests');
  static String get requestApproved => _tr('تم قبول الطلب', 'Request approved');
  static String get requestRejected => _tr('تم رفض الطلب', 'Request rejected');
  static String get approve => _tr('قبول', 'Approve');
  static String get reject => _tr('رفض', 'Reject');
  static String get joinRequestFrom => _tr('طلب انضمام من', 'Join request from');
  static String get approveJoinConfirm => _tr('سيتم إضافة العضو إلى الفريق. هل أنت متأكد؟', 'The member will be added to the team. Are you sure?');
  static String get rejectJoinConfirm => _tr('سيتم رفض طلب الانضمام. هل أنت متأكد؟', 'The join request will be rejected. Are you sure?');
  static String get joinRequestPermissions => _tr('صلاحيات العضو', 'Member Permissions');
  static String get changeRole => _tr('تغيير الدور', 'Change Role');
  static String get noOtherRoles => _tr('لا توجد أدوار أخرى متاحة', 'No other roles available');
  static String get selectRole => _tr('اختر الدور', 'Select Role');
  static String get doubleTapToExit => _tr('اضغط مرة أخرى للخروج', 'Press again to exit');
  static String get productsSection => _tr('المنتجات', 'Products');
  static String get viewProducts => _tr('عرض المنتجات', 'View Products');
  static String get createProducts => _tr('إضافة منتجات', 'Add Products');
  static String get editProducts => _tr('تعديل المنتجات', 'Edit Products');
  static String get deleteProducts => _tr('حذف المنتجات', 'Delete Products');
  static String get salesSection => _tr('المبيعات', 'Sales');
  static String get viewSales => _tr('عرض المبيعات', 'View Sales');
  static String get createSales => _tr('إضافة فاتورة مبيعات', 'Add Sales Invoice');
  static String get purchasesSection => _tr('المشتريات', 'Purchases');
  static String get viewPurchases => _tr('عرض المشتريات', 'View Purchases');
  static String get createPurchases => _tr('إضافة فاتورة مشتريات', 'Add Purchase Invoice');
  static String get otherSection => _tr('أخرى', 'Other');
  static String get viewInventory => _tr('عرض المخزون', 'View Inventory');
  static String get viewCustomers => _tr('عرض العملاء', 'View Customers');
  static String get createCustomers => _tr('إضافة عملاء', 'Add Customers');
  static String get viewReports => _tr('عرض التقارير', 'View Reports');
  static String get manageTeam => _tr('إدارة الفريق', 'Manage Team');
  static String get manageSettings => _tr('إدارة الإعدادات', 'Manage Settings');
  static String get unknownUser => _tr('مستخدم غير معروف', 'Unknown User');
  static String get removeMember => _tr('حذف عضو', 'Remove Member');
  static String get removeMemberConfirm => _tr('هل أنت متأكد من حذف', 'Are you sure you want to remove');
  static String get remove => _tr('حذف', 'Remove');
  static String get companyLeft => _tr('تم الخروج من الشركة بنجاح', 'Left company successfully');
  static String get companyDeleted => _tr('تم حذف الشركة بنجاح', 'Company deleted successfully');
  static String get sectionProducts => _tr('المنتجات', 'Products');
  static String get sectionCustomers => _tr('العملاء', 'Customers');
  static String get sectionInvoices => _tr('الفواتير', 'Invoices');
  static String get sectionPayments => _tr('المدفوعات', 'Payments');
  static String get sectionReports => _tr('التقارير', 'Reports');
  static String get sectionDashboard => _tr('لوحة البيانات', 'Dashboard');
  static String get sectionAdmin => _tr('الإدارة', 'Administration');
  static String get permView => _tr('عرض المنتجات', 'View Products');
  static String get permCreate => _tr('إضافة منتج جديد', 'Add New Product');
  static String get permUpdate => _tr('تعديل بيانات المنتج', 'Edit Product');
  static String get permDelete => _tr('حذف المنتجات', 'Delete Products');
  static String get permCustomersView => _tr('عرض العملاء', 'View Customers');
  static String get permCustomersCreate => _tr('إضافة عميل جديد', 'Add New Customer');
  static String get permCustomersUpdate => _tr('تعديل بيانات العميل', 'Edit Customer');
  static String get permCustomersDelete => _tr('حذف العملاء', 'Delete Customers');
  static String get permInvoicesView => _tr('عرض الفواتير', 'View Invoices');
  static String get permInvoicesCreate => _tr('إنشاء فاتورة', 'Create Invoice');
  static String get permInvoicesUpdate => _tr('تعديل الفاتورة', 'Edit Invoice');
  static String get permInvoicesDelete => _tr('حذف الفاتورة', 'Delete Invoice');
  static String get permPaymentsView => _tr('عرض المدفوعات', 'View Payments');
  static String get permPaymentsCreate => _tr('استلام مدفوعات', 'Receive Payments');
  static String get permPaymentsUpdate => _tr('تعديل المدفوعات', 'Edit Payments');
  static String get permReportsView => _tr('عرض تقارير المبيعات', 'View Sales Reports');
  static String get permExportExcel => _tr('تصدير Excel', 'Export Excel');
  static String get permManageTeam => _tr('إدارة الفريق', 'Manage Team');
  static String get permSystemSettings => _tr('إعدادات النظام', 'System Settings');
  static String get permDashboardView => _tr('عرض لوحة البيانات', 'View Dashboard');
  static String get permUsersManage => _tr('إدارة المستخدمين', 'Manage Users');
  static String get companyManagement => _tr('إدارة الشركة', 'Company Management');
  static String get customers => _tr('العملاء', 'Customers');
  static String get products => _tr('المنتجات', 'Products');
  static String get invoices => _tr('الفواتير', 'Invoices');
  static String get payments => _tr('المدفوعات', 'Payments');
  static String get other => _tr('أخرى', 'Other');
  static String get permissionView => _tr('عرض', 'View');
  static String get permissionCreate => _tr('إضافة', 'Create');
  static String get permissionUpdate => _tr('تعديل', 'Edit');
  static String get permissionDelete => _tr('حذف', 'Delete');
  static String get permissionManage => _tr('إدارة', 'Manage');
  static String get ownerRole => _tr('مالك', 'Owner');
  static String get members => _tr('الأعضاء', 'Members');
  static String get switchCompany => _tr('تغيير الشركة', 'Switch Company');
  static String get signOut => _tr('تسجيل الخروج', 'Sign Out');

  // ── Onboarding / Welcome ──────────────────────────────────────────────
  static String get welcomeTitle => _tr('مرحباً بك في\nMakhzanFlow', 'Welcome to\nMakhzanFlow');
  static String get welcomeSubtitle => _tr('أدِر مخزونك ومبيعاتك وفريقك\nمن مكان واحد', 'Manage your inventory, sales, and team\nfrom one place');
  static String get welcomeAppSubtitle => _tr('نظام إدارة المخازن والفرق', 'Warehouse & Team Management System');
  static String get createBusiness => _tr('إنشاء عمل تجاري', 'Create a Business');
  static String get joinBusiness => _tr('الانضمام لعمل تجاري', 'Join a Business');
  static String get selectBusiness => _tr('اختر العمل التجاري', 'Select Business');
  static String get createNewBusiness => _tr('إنشاء عمل تجاري جديد', 'Create New Business');
  static String get joinByCode => _tr('الانضمام برمز دعوة', 'Join by Invite Code');
  static String get joinCompany => _tr('انضمام لشركة', 'Join Company');
  static String get businessType => _tr('نوع النشاط', 'Business Type');
  static String get businessTypeHint => _tr('اختر نوع النشاط التجاري', 'Select business type');
  static String get inviteCode => _tr('رمز الدعوة', 'Invite Code');
  static String get inviteCodeTitle => _tr('أدخل رمز الدعوة', 'Enter Invite Code');
  static String get inviteCodeSubtitle => _tr('قم بإدخال رمز الدعوة المرسل من مالك الشركة', 'Enter the invite code sent by the company owner');
  static String get inviteCodeRequired => _tr('يرجى إدخال رمز الدعوة', 'Please enter the invite code');
  static String get joinButton => _tr('انضمام', 'Join');
  static String get pendingTitle => _tr('بانتظار الموافقة', 'Awaiting Approval');
  static String get pendingSubtitle => _tr('تم إرسال طلب الانضمام إلى مالك الشركة\nسيتم تحويلك إلى لوحة التحكم عند الموافقة', 'Your join request has been sent to the company owner\nYou will be redirected to the dashboard upon approval');
  static String get pendingChecking => _tr('جاري التحقق من حالة الطلب...', 'Checking request status...');
  static String get logoPickerHint => _tr('إضافة شعار', 'Add Logo');

  // ── Dashboard ─────────────────────────────────────────────────────────
  static String get dashboardGreeting => _tr('مرحباً', 'Hello');
  static String get dashboardTodaySales => _tr('تحصيلات اليوم', "Today's Collections");
  static String get dashboardProductsCount => _tr('عدد المنتجات', 'Products Count');
  static String get dashboardTotalDebts => _tr('إجمالي الديون', 'Total Debts');
  static String get dashboardCustomersCount => _tr('عدد العملاء', 'Customers Count');
  static String get dashboardMonthlyProfit => _tr('أرباح الشهر', 'Monthly Profit');
  static String get dashboardWeeklySales => _tr('مبيعات الأسبوع', 'Weekly Sales');
  static String get dashboardWeeklySalesSubtitle => _tr('آخر ٧ أيام', 'Last 7 days');
  static String get dashboardTodayProfit => _tr('أرباح اليوم', "Today's Profit");
  static String get dashboardTodayProfitSubtitle => _tr('صافي الربح بعد الخصومات', 'Net profit after discounts');
  static String get dashboardQuickInvoice => _tr('فاتورة', 'Invoice');
  static String get dashboardQuickProduct => _tr('منتج', 'Product');
  static String get dashboardQuickReport => _tr('تقرير', 'Report');
  static String get dashboardQuickExcel => 'Excel';
  static String get dashboardQuickActions => _tr('إجراءات سريعة', 'Quick Actions');
  static String get dashboardRecentActivity => _tr('آخر النشاطات', 'Recent Activity');
  static String get dashboardRecentActivitySubtitle => _tr('آخر ٥ عمليات تمت في النشاط', 'Last 5 activity operations');
  static String get dashboardQuickCustomer => _tr('عميل', 'Customer');
  static String get activityJustNow => _tr('الآن', 'Just now');
  static String get activityMinutes => _tr('دقيقة', 'minutes');
  static String get activityHours => _tr('ساعة', 'hours');
  static String get activityDays => _tr('يوم', 'days');
  static String get dashboardErrorTitle => _tr('فشل تحميل بيانات لوحة التحكم', 'Failed to load dashboard data');
  static String get dashboardTodayBadge => _tr('اليوم', 'Today');
  static String get dashboardMonthlyPayments => _tr('مدفوعات الشهر', 'Monthly Payments');
  static String get dashboardMonthlyPaymentsSubtitle => _tr('إجمالي المقبوضات النقدية', 'Total cash receipts');

  // ── Products ──────────────────────────────────────────────────────────
  static String get productsSearchHint => _tr('ابحث عن منتج...', 'Search for a product...');
  static String get productsAdd => _tr('إضافة منتج جديد', 'Add New Product');
  static String get productsTitle => _tr('المنتجات', 'Products');
  static String get productLowStock => _tr('منخفض', 'Low');
  static String get productCategoryAll => _tr('الكل', 'All');
  static String get productNameLabel => _tr('اسم المنتج', 'Product Name');
  static String get productNameHint => _tr('أدخل اسم المنتج', 'Enter product name');
  static String get productSkuLabel => _tr('كود المنتج (SKU)', 'Product Code (SKU)');
  static String get productSkuHint => _tr('اتركه فارغاً للتوليد التلقائي', 'Leave empty for auto-generation');
  static String get productBarcodeLabel => _tr('الباركود', 'Barcode');
  static String get productBarcodeHint => _tr('اختياري', 'Optional');
  static String get productPriceLabel => _tr('السعر', 'Price');
  static String get productPriceHint => _tr('٠٫٠٠', '0.00');
  static String get productQuantityLabel => _tr('الكمية', 'Quantity');
  static String get productQuantityHint => _tr('٠', '0');
  static String get productMinStockLabel => _tr('الحد الأدنى للمخزون', 'Minimum Stock');
  static String get productMinStockHint => _tr('٠', '0');
  static String get productImagePicker => _tr('اختر صورة', 'Choose Image');
  static String get productImageGallery => _tr('المعرض', 'Gallery');
  static String get productImageCamera => _tr('الكاميرا', 'Camera');
  static String get productSave => _tr('حفظ', 'Save');
  static String get productCancel => _tr('إلغاء', 'Cancel');
  static String get productDelete => _tr('حذف', 'Delete');
  static String get productDeleteConfirm => _tr('هل أنت متأكد من حذف هذا المنتج؟', 'Are you sure you want to delete this product?');
  static String get productDeleted => _tr('تم حذف المنتج بنجاح', 'Product deleted successfully');
  static String get productSaved => _tr('تم حفظ المنتج بنجاح', 'Product saved successfully');
  static String get productQuantityUpdate => _tr('تحديث الكمية', 'Update Quantity');
  static String get productQuantityIn => _tr('إضافة', 'Add');
  static String get productQuantityOut => _tr('سحب', 'Remove');
  static String get productQuantityNote => _tr('سبب التعديل', 'Reason for adjustment');
  static String get productQuantityUpdated => _tr('تم تحديث الكمية بنجاح', 'Quantity updated successfully');
  static String get productImageUploading => _tr('جاري رفع الصورة...', 'Uploading image...');
  static String get productSaving => _tr('جاري الحفظ...', 'Saving...');
  static String get productNotFound => _tr('المنتج غير موجود', 'Product not found');
  static String get productEmptySearch => _tr('لا توجد نتائج للبحث', 'No search results');
  static String get productRetry => _tr('إعادة المحاولة', 'Retry');
  static String get productDetails => _tr('تفاصيل المنتج', 'Product Details');
  static String get productEdit => _tr('تعديل المنتج', 'Edit Product');
  static String get productMovementHistory => _tr('حركة المخزون', 'Stock Movement');
  static String get productEditTitle => _tr('تعديل: ', 'Edit: ');
  static String get productNameRequired => _tr('يرجى إدخال اسم المنتج', 'Please enter the product name');
  static String get productPriceRequired => _tr('يرجى إدخال السعر', 'Please enter the price');
  static String get productPriceInvalid => _tr('السعر غير صالح', 'Invalid price');
  static String get productQuantityRequired => _tr('يرجى إدخال الكمية', 'Please enter the quantity');
  static String get productQuantityInvalid => _tr('الكمية غير صالحة', 'Invalid quantity');
  static String get productLoadError => _tr('حدث خطأ أثناء تحميل المنتجات', 'Error loading products');
  static String get productSaveError => _tr('حدث خطأ أثناء حفظ المنتج', 'Error saving product');
  static String get productDeleteError => _tr('حدث خطأ أثناء حذف المنتج', 'Error deleting product');
  static String get productImageError => _tr('حدث خطأ أثناء رفع الصورة', 'Error uploading image');
  static String get productQuantityError => _tr('حدث خطأ أثناء تحديث الكمية', 'Error updating quantity');
  static String get productNegativeQuantity => _tr('لا يمكن أن تصبح الكمية أقل من صفر', 'Quantity cannot be less than zero');
  static String get productCount => _tr('عدد المنتجات', 'Products Count');
  static String get productExpirationDateLabel => _tr('تاريخ انتهاء الصلاحية', 'Expiration Date');
  static String get productExpirationDateHint => _tr('اختر تاريخ انتهاء الصلاحية', 'Select expiration date');
  static String get productExpired => _tr('منتهي', 'Expired');
  static String get productExpiringSoon => _tr('قريب الانتهاء', 'Expiring Soon');
  static String get productOutOfStock => _tr('نفذ من المخزون', 'Out of Stock');

  // ── Empty States ──────────────────────────────────────────────────────
  static String get emptyProducts => _tr('لا توجد منتجات حالياً', 'No products yet');
  static String get emptyCustomers => _tr('لا يوجد عملاء حالياً', 'No customers yet');
  static String get emptyInvoices => _tr('لا توجد فواتير حالياً', 'No invoices yet');
  static String get emptyActivity => _tr('لا توجد نشاطات حديثة', 'No recent activity');

  // ── Customers ─────────────────────────────────────────────────────────
  static String get customersTitle => _tr('العملاء', 'Customers');
  static String get customersSearchHint => _tr('ابحث عن عميل...', 'Search for a customer...');
  static String get customerAdd => _tr('إضافة عميل جديد', 'Add New Customer');
  static String get customerEdit => _tr('تعديل العميل', 'Edit Customer');
  static String get customerDetails => _tr('تفاصيل العميل', 'Customer Details');
  static String get customerAddSuccess => _tr('تم إضافة العميل بنجاح', 'Customer added successfully');
  static String get customerSaveSuccess => _tr('تم حفظ العميل بنجاح', 'Customer saved successfully');
  static String get customerNameLabel => _tr('اسم المتجر', 'Store Name');
  static String get customerNameHint => _tr('مثال: سوبر ماركت الأمانة', 'e.g. Al-Amana Supermarket');
  static String get customerNameRequired => _tr('يرجى إدخال اسم المتجر', 'Please enter the store name');
  static String get customerOfficialNameLabel => _tr('اسم المسؤول', "Manager's Name");
  static String get customerOfficialNameHint => _tr('مثال: محمد أحمد', 'e.g. Mohamed Ahmed');
  static String get customerPhoneLabel => _tr('رقم الهاتف', 'Phone Number');
  static String get customerPhoneHint => _tr('مثال: 01234567890', 'e.g. 01234567890');
  static String get customerAddressLabel => _tr('العنوان', 'Address');
  static String get customerAddressHint => _tr('مثال: شارع الجمهورية، القاهرة', 'e.g. Republic Street, Cairo');
  static String get customerDebtLabel => _tr('الديون السابقة', 'Previous Debts');
  static String get customerDebtHint => _tr('٠٫٠٠', '0.00');
  static String get customerDebtReadonly => _tr('لتعديلها أضف دفعة', 'Add a payment to edit');
  static String get customerAddImage => _tr('إضافة صورة', 'Add Image');
  static String get customerCancel => _tr('إلغاء', 'Cancel');
  static String get customerSave => _tr('حفظ التعديلات', 'Save Changes');
  static String get customerAddButton => _tr('إضافة العميل', 'Add Customer');
  static String get customerRetry => _tr('إعادة المحاولة', 'Retry');
  static String get customerEmptySearch => _tr('لا توجد نتائج للبحث', 'No search results');
  static String get customerLoadError => _tr('حدث خطأ أثناء تحميل العملاء', 'Error loading customers');
  static String get customerDebtTotal => _tr('إجمالي المديونية', 'Total Debt');
  static String get customerDebtEditNote => _tr('لتعديلها أضف دفعة', 'Add a payment to edit');
  static String get customerOutstandingBalance => _tr('الرصيد المستحق', 'Outstanding Balance');
  static String get customerPaymentRatio => _tr('نسبة السداد', 'Payment Ratio');
  static String get customerPaidPercent => _tr('٪ مدفوع', '% Paid');
  static String get customerTotalPurchases => _tr('إجمالي المشتريات', 'Total Purchases');
  static String get customerPaidLabel => _tr('المدفوع', 'Paid');
  static String get customerRemainingLabel => _tr('المتبقي', 'Remaining');
  static String get customerNewInvoice => _tr('فاتورة جديدة', 'New Invoice');
  static String get customerRecordPayment => _tr('تسجيل دفعة', 'Record Payment');
  static String get customerTransactionsTab => _tr('المعاملات', 'Transactions');
  static String get customerPaymentsTab => _tr('المدفوعات', 'Payments');
  static String get customerTransactionLog => _tr('سجل المعاملات', 'Transaction Log');
  static String get customerViewAll => _tr('عرض الكل', 'View All');
  static String get customerCashPayment => _tr('دفعة نقدية', 'Cash Payment');
  static String get customerBankTransfer => _tr('تحويل بنكي', 'Bank Transfer');
  static String get customerReceived => _tr('مستلم', 'Received');
  static String get customerInvoiceLabel => _tr('فاتورة', 'Invoice');
  static String get customerDeferred => _tr('آجل', 'Deferred');
  static String get customerCash => _tr('نقدي', 'Cash');
  static String get customerMeeza => _tr('ميزة', 'Meeza');
  static String get customerYesterday => _tr('أمس', 'Yesterday');
  static String get customerDaysAgo => _tr('قبل', 'ago');
  static String get customerInvoicePrefix => '#';
  static String get customerDay => _tr('يوم', 'day');
  static String get customerDays => _tr('أيام', 'days');
  static String get customerWeek => _tr('أسبوع', 'week');
  static String get customerWeeks => _tr('أسبوعين', 'weeks');
  static String get customerProductsUnit => _tr('منتجات', 'products');

  // ── Customers List (Figma redesign) ──────────────────────────────────
  static String get customerAllFilter => _tr('الكل', 'All');
  static String get customerPaidFilter => _tr('مدفوع', 'Paid');
  static String get customerPartialFilter => _tr('جزئي', 'Partial');
  static String get customerDeferredFilter => _tr('آجل', 'Deferred');
  static String get customerDebtsLabel => _tr('ديون', 'Debts');
  static String get customerStore => _tr('سوبر ماركت', 'Supermarket');
  static String get customerInvoicesTab => _tr('فاتورات', 'Invoices');

  // ── Invoice — Create ──────────────────────────────────────────────────
  static String get invoiceNew => _tr('فاتورة جديدة', 'New Invoice');
  static String get invoiceCreateSale => _tr('إنشاء فاتورة بيع', 'Create Sales Invoice');
  static String get productsCount => _tr('المنتجات', 'Products');
  static String get addProduct => _tr('إضافة منتج', 'Add Product');
  static String get discountLabel => _tr('الخصم', 'Discount');
  static String get byAmount => _tr('بالمبلغ', 'By Amount');
  static String get byPercentage => _tr('بالنسبة %', 'By Percentage %');
  static String get discountValueSuffix => _tr('ج.م', 'EGP');
  static String get discountPercentSuffix => '%';
  static String get paymentMethod => _tr('طريقة الدفع', 'Payment Method');
  static String get fullPayment => _tr('دفع كامل', 'Full Payment');
  static String get partialPayment => _tr('دفع جزئي', 'Partial Payment');
  static String get deferredPayment => _tr('آجل', 'Deferred');
  static String get howMuchPaidNow => _tr('كم تدفع الآن؟', 'How much to pay now?');
  static String get paidNowHint => _tr('٠', '0');
  static String get remainingDebt => _tr('المتبقي (دين)', 'Remaining (Debt)');
  static String get subtotal => _tr('المجموع الفرعي', 'Subtotal');
  static String get afterDiscount => _tr('بعد الخصم', 'After Discount');
  static String get totalLabel => _tr('الإجمالي', 'Total');
  static String get paidNowLabel => _tr('المدفوع الآن', 'Paid Now');
  static String get confirmAndIssue => _tr('تأكيد وإصدار الفاتورة', 'Confirm & Issue Invoice');
  static String get customerSection => _tr('العميل', 'Customer');
  static String get selectCustomer => _tr('اختر عميل', 'Select Customer');
  static String get invoiceTotalPrefix => _tr('الإجمالي', 'Total');
  static String get invoiceItemsCount => _tr('منتجات', 'products');
  static String get discountAmount => _tr('قيمة الخصم', 'Discount Amount');
  static String get discountNone => _tr('بدون خصم', 'No discount');
  static String get discountPercentError => _tr('نسبة الخصم لا تتجاوز 100%', 'Discount percentage cannot exceed 100%');
  static String get discountAmountError => _tr('قيمة الخصم لا تتجاوز إجمالي الفاتورة', 'Discount amount cannot exceed invoice total');
  static String get paidNowExceedError => _tr('المدفوع الآن لا يتجاوز إجمالي الفاتورة', 'Paid amount cannot exceed invoice total');

  // ── Invoice — Product Picker ──────────────────────────────────────────
  static String get searchProduct => _tr('ابحث عن منتج بالاسم أو الباركود...', 'Search by product name or barcode...');
  static String get scanBarcode => _tr('مسح الباركود', 'Scan Barcode');
  static String get categoryGrains => _tr('الحبوب', 'Grains');
  static String get categoryOils => _tr('الزيوت', 'Oils');
  static String get categoryBeverages => _tr('المشروبات', 'Beverages');
  static String get categoryLegumes => _tr('البقوليات', 'Legumes');
  static String get categoryCanned => _tr('المعلقات', 'Canned Goods');
  static String get selectedProducts => _tr('منتجات محددة', 'Selected Products');
  static String get showDetails => _tr('عرض التفاصيل', 'Show Details');
  static String get addNProducts => _tr('إضافة منتجات إلى الفاتورة', 'Add products to invoice');
  static String get productsAvailable => _tr('منتج متاح', 'product available');
  static String get stockLabel => _tr('المخزون: ', 'Stock: ');
  static String get productPickerTitle => _tr('إضافة منتج', 'Add Product');
  static String get done => _tr('تم', 'Done');
  static String get cancel => _tr('إلغاء', 'Cancel');

  // ── Invoice — Details ─────────────────────────────────────────────────
  static String get invoiceDetailsTitle => _tr('تفاصيل الفاتورة', 'Invoice Details');
  static String get invoiceNo => _tr('فاتورة', 'Invoice');
  static String get printInvoice => _tr('طباعة الفاتورة', 'Print Invoice');
  static String get shareInvoice => _tr('مشاركة', 'Share');
  static String get cancelInvoice => _tr('إلغاء الفاتورة', 'Cancel Invoice');
  static String get cancelInvoiceConfirmTitle => _tr('تأكيد الإلغاء', 'Confirm Cancellation');
  static String get cancelInvoiceConfirmBody => _tr('هل أنت متأكد من إلغاء هذه الفاتورة؟ سيتم إرجاع الكميات إلى المخزون ولا يمكن التراجع.', 'Are you sure you want to cancel this invoice? Stock quantities will be restored and this cannot be undone.');
  static String get cancelInvoiceSuccess => _tr('تم إلغاء الفاتورة وإرجاع المخزون', 'Invoice canceled and stock restored');
  static String get cancelInvoiceAction => _tr('تأكيد الإلغاء', 'Confirm Cancellation');
  static String get cancelInvoiceStockNote => _tr('سيتم إرجاع المنتجات إلى المخزون تلقائياً', 'Products will be automatically restored to stock');
  static String get mainWarehouse => _tr('مخزن التوزيع الرئيسي', 'Main Distribution Warehouse');
  static String get invoiceNumber => _tr('رقم الفاتورة', 'Invoice Number');
  static String get date => _tr('التاريخ', 'Date');
  static String get employee => _tr('الموظف', 'Employee');
  static String get productCol => _tr('المنتج', 'Product');
  static String get qtyCol => _tr('الكمية', 'Qty');
  static String get priceCol => _tr('السعر', 'Price');
  static String get totalCol => _tr('الإجمالي', 'Total');
  static String get tax => _tr('الضريبة', 'Tax');
  static String get paymentHistory => _tr('سجل المدفوعات', 'Payment History');
  static String get paymentReminder => _tr('المبلغ المتبقي مستحق خلال ٧ أيام', 'Remaining amount due within 7 days');
  static String get selectProducts => _tr('اختيار منتجات', 'Select Products');
  static String get invoiceSaved => _tr('تم حفظ الفاتورة بنجاح', 'Invoice saved successfully');
  static String get invoiceSaveError => _tr('حدث خطأ أثناء حفظ الفاتورة', 'Error saving invoice');
  static String get invoiceCreated => _tr('تم إنشاء الفاتورة بنجاح', 'Invoice created successfully');
  static String get invoiceCreatedAt => _tr('تم إنشاؤها', 'Created');

  // ── Payment — Add Payment Screen ──────────────────────────────────────
  static String get addPaymentTitle => _tr('تسجيل دفعة جديدة', 'Record New Payment');
  static String get addPaymentTotalSelected => _tr('إجمالي المبلغ المحدد', 'Total Selected Amount');
  static String get addPaymentAmountLabel => _tr('مبلغ الدفعة', 'Payment Amount');
  static String get addPaymentAmountHint => _tr('٠٫٠٠', '0.00');
  static String get addPaymentSelectInvoices => _tr('اختر الفواتير غير المدفوعة', 'Select unpaid invoices');
  static String get addPaymentInvoicesSelected => _tr('فواتير محددة', 'invoices selected');
  static String get addPaymentSave => _tr('حفظ الدفعة', 'Save Payment');
  static String get addPaymentSuccess => _tr('تم تسجيل الدفعة بنجاح', 'Payment recorded successfully');
  static String get addPaymentStatusPartial => _tr('جزئي', 'Partial');
  static String get addPaymentStatusDebt => _tr('آجل', 'Deferred');
  static String get addPaymentTotal => _tr('إجمالي الفاتورة: ', 'Invoice Total: ');
  static String get addPaymentInvoicePrefix => '#';

  // ── Company Switcher ──────────────────────────────────────────────────
  static String get noCompanies => _tr('لا توجد شركات', 'No companies');

  // ── Email Verification ────────────────────────────────────────────────
  static String get emailVerificationTitle => _tr('تحقق من بريدك الإلكتروني', 'Verify Your Email');
  static String get emailVerificationSubtitle => _tr('تم إرسال رمز التحقق إلى', 'A verification code has been sent to');
  static String get verify => _tr('تحقق', 'Verify');
  static String get resendCode => _tr('إعادة إرسال الرمز', 'Resend Code');
  static String get backToLogin => _tr('العودة إلى تسجيل الدخول', 'Back to Login');
  static String get pleaseEnterVerificationCode => _tr('يرجى إدخال رمز التحقق', 'Please enter the verification code');
  static String get verificationCodeResent => _tr('تم إعادة إرسال رمز التحقق', 'Verification code resent');

  // ── Pending Approval ──────────────────────────────────────────────────
  static String get joinRequestNotApprovedDesc => _tr('لم يتم الموافقة على طلب الانضمام', 'Join request has not been approved');
  static String get requestCancelled => _tr('تم إلغاء الطلب', 'Request cancelled');

  // ── Company Settings & Invite Code ────────────────────────────────────
  static String get viewInviteCode => _tr('عرض رمز الدعوة', 'View Invite Code');
  static String get viewTeam => _tr('عرض فريق العمل', 'View Team');
  static String get dangerZone => _tr('منطقة الخطر', 'Danger Zone');
  static String get deleteCompany => _tr('حذف الشركة', 'Delete Company');
  static String get deleteCompanyConfirm => _tr('هل أنت متأكد من حذف الشركة؟ لا يمكن التراجع عن هذا الإجراء.', 'Are you sure you want to delete the company? This action cannot be undone.');
  static String get deleteAction => _tr('حذف', 'Delete');
  static String get leaveCompany => _tr('مغادرة الشركة', 'Leave Company');
  static String get leaveCompanyConfirm => _tr('هل أنت متأكد من مغادرة هذه الشركة؟', 'Are you sure you want to leave this company?');
  static String get leaveAction => _tr('مغادرة', 'Leave');
  static String get changeInviteCode => _tr('تغيير رمز الدعوة', 'Change Invite Code');
  static String get changeInviteCodeConfirm => _tr('سيتم تعطيل الرمز الحالي وإنشاء رمز جديد. هل أنت متأكد؟', 'The current code will be disabled and a new one created. Are you sure?');
  static String get confirm => _tr('تأكيد', 'Confirm');
  static String get codeCopied => _tr('تم نسخ الرمز', 'Code copied');
  static String get inviteCodeChanged => _tr('تم تغيير رمز الدعوة', 'Invite code changed');
  static String get inviteCodeChangeFailed => _tr('فشل تغيير رمز الدعوة', 'Failed to change invite code');
  static String get inviteCodeLoadFailed => _tr('فشل تحميل رمز الدعوة', 'Failed to load invite code');

  // ── Members Page ──────────────────────────────────────────────────────
  static String get ownersTitle => _tr('المالكين', 'Owners');
  static String get employeesTitle => _tr('الموظفين', 'Employees');
  static String get inactiveMembersTitle => _tr('الأعضاء غير النشطين', 'Inactive Members');
  static String get deactivateMemberTitle => _tr('إلغاء تنشيط العضو', 'Deactivate Member');
  static String get reactivateMemberTitle => _tr('إعادة تنشيط العضو', 'Reactivate Member');
  static String get promoteToOwnerTitle => _tr('ترقية إلى مالك', 'Promote to Owner');
  static String get demoteToMemberTitle => _tr('تنزيل إلى موظف', 'Demote to Employee');
  static String get promoteAction => _tr('ترقية', 'Promote');
  static String get demoteAction => _tr('تنزيل', 'Demote');
  static String get deactivateAction => _tr('إلغاء التنشيط', 'Deactivate');
  static String get reactivateAction => _tr('إعادة تنشيط', 'Reactivate');
  static String get rejectJoinTitle => _tr('رفض طلب الانضمام', 'Reject Join Request');
  static String deactivateConfirm(String name) =>
      _tr('سيتم تعطيل حساب $name. هل أنت متأكد؟', "The account for $name will be deactivated. Are you sure?");
  static String reactivateConfirm(String name) =>
      _tr('سيتم إعادة تفعيل حساب $name. هل أنت متأكد؟', "The account for $name will be reactivated. Are you sure?");
  static String promoteConfirm(String name) =>
      _tr('سيتم ترقية $name إلى مالك. هل أنت متأكد؟', "$name will be promoted to owner. Are you sure?");
  static String demoteConfirm(String name) =>
      _tr('سيتم تحويل $name من مالك إلى موظف. هل أنت متأكد؟', "$name will be demoted from owner to employee. Are you sure?");

  // ── Edit Member Permissions ───────────────────────────────────────────
  static String permissionsTitle(String name) => _tr('صلاحيات $name', "$name's Permissions");
  static String get ownerFullAccess => _tr('مالك - صلاحية كاملة', 'Owner - Full Access');
  static String get permissionsSaved => _tr('تم حفظ الصلاحيات بنجاح', 'Permissions saved successfully');

  // ── Member Card ───────────────────────────────────────────────────────
  static String get inactiveBadge => _tr('غير نشط', 'Inactive');
  static String get fullAccess => _tr('صلاحية كاملة', 'Full Access');
  static String get employeeRole => _tr('موظف', 'Employee');
  static String get permissionsLabel => _tr('الصلاحيات', 'Permissions');
  static String get promoteToOwnerLabel => _tr('ترقية إلى مالك', 'Promote to Owner');
  static String get demoteToEmployeeLabel => _tr('تنزيل إلى موظف', 'Demote to Employee');
  static String get deactivateLabel => _tr('إلغاء التنشيط', 'Deactivate');
  static String get reactivateLabel => _tr('إعادة تنشيط', 'Reactivate');

  // ── App Shell / Sidebar ───────────────────────────────────────────────
  static String get branchFallback => _tr('فرع الإسماعيلية', 'Ismailia Branch');
  static String get ownerLabel => _tr('مالك', 'Owner');
  static String get ownerLabelEn => _tr('مالك', 'Owner');
  static String get lightMode => _tr('فاتح', 'Light');
  static String get darkMode => _tr('داكن', 'Dark');
  static String get lightModeEn => _tr('فاتح', 'Light');
  static String get darkModeEn => _tr('داكن', 'Dark');
  static String get cancelInvoiceBadge => _tr('إلغاء', 'Cancel');
  static String get invoiceCanceledNote => _tr('هذه الفاتورة ملغاة وتم إرجاع المنتجات إلى المخزون', 'This invoice is canceled and products have been restored to stock');

  // ── Customer Transaction Labels (used in CustomerModel.fromJson) ──────
  static String get transactionOpeningDebt => _tr('رصيد افتتاحي', 'Opening Balance');
  static String get transactionOpeningDebtSubtitle => _tr('عند إنشاء الحساب', 'When account was created');
  static String get transactionPending => _tr('معلق', 'Pending');
  static String get transactionDeferred => _tr('آجل', 'Deferred');
  static String get transactionPaid => _tr('مدفوع', 'Paid');
  static String get transactionPartial => _tr('مدفوع جزئياً', 'Partially Paid');
  static String transactionSalesInvoice(String id) =>
      _tr('فاتورة مبيعات #$id', 'Sales Invoice #$id');
  static String transactionRemaining(String amount) =>
      _tr('$amount ج.م متبقي', '$amount EGP remaining');
  static String get transactionCashPayment => _tr('سداد دفعة نقداً', 'Cash Payment');
  static String get transactionCashPaymentSubtitle => _tr('تم الاستلام بنجاح', 'Received successfully');
  static String get transactionReceived => _tr('مستلم', 'Received');
}
