import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:makhzanflow/core/theme/app_locale_cubit.dart';
import 'package:makhzanflow/core/api/api_client.dart';
import 'package:makhzanflow/core/storage/file_upload_service.dart';
import 'package:makhzanflow/core/storage/token_storage.dart';
import 'package:makhzanflow/core/company/company_cubit.dart';
import 'package:makhzanflow/core/permissions/permission_service.dart';
import 'package:makhzanflow/core/permissions/permission_service_impl.dart';
import 'package:makhzanflow/features/companies/data/datasources/company_remote_data_source.dart';
import 'package:makhzanflow/features/companies/data/datasources/company_remote_data_source_impl.dart';
import 'package:makhzanflow/features/companies/data/repositories/company_repository_impl.dart';
import 'package:makhzanflow/features/companies/domain/repositories/company_repository.dart';
import 'package:makhzanflow/features/companies/domain/usecases/create_company_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_company_members_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_company_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_user_companies_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/invite_member_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/remove_member_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/update_company_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/update_member_permissions_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/join_company_by_code_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/approve_join_request_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/reject_join_request_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_join_requests_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/check_join_request_status_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/create_company_full_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/cancel_join_request_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_company_join_code_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/regenerate_company_join_code_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/deactivate_member_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/reactivate_member_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/remove_company_member_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/promote_member_to_owner_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/demote_owner_to_member_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/get_member_permissions_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/leave_company_usecase.dart';
import 'package:makhzanflow/features/companies/domain/usecases/delete_company_usecase.dart';
import 'package:makhzanflow/features/companies/presentation/cubit/join_company_cubit.dart';
import 'package:makhzanflow/features/companies/presentation/cubit/company_members_cubit.dart';
import 'package:makhzanflow/features/companies/presentation/cubit/company_settings_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_state_changes_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/verify_email_usecase.dart';
import '../../features/auth/domain/usecases/resend_verification_email_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/datasources/product_remote_data_source_impl.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/domain/usecases/create_product_usecase.dart';
import '../../features/products/domain/usecases/upload_product_image_usecase.dart';
import '../../features/products/domain/usecases/get_product_usecase.dart';
import '../../features/products/domain/usecases/update_product_usecase.dart';
import '../../features/products/domain/usecases/delete_product_usecase.dart';
import '../../features/products/domain/usecases/update_product_quantity_usecase.dart';
import '../../features/products/domain/usecases/get_inventory_movements_usecase.dart';
import '../../features/products/presentation/cubit/products/products_cubit.dart';
import '../../features/products/presentation/cubit/add_edit_product/add_edit_product_cubit.dart';
import '../../features/products/presentation/cubit/product_details/product_details_cubit.dart';
import '../../features/customers/data/datasources/customer_remote_data_source.dart';
import '../../features/customers/data/datasources/customer_remote_data_source_impl.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/get_customers_usecase.dart';
import '../../features/customers/domain/usecases/get_customer_filter_counts_usecase.dart';
import '../../features/customers/domain/usecases/create_customer_usecase.dart';
import '../../features/customers/domain/usecases/upload_customer_image_usecase.dart';
import '../../features/customers/domain/usecases/get_customer_usecase.dart';
import '../../features/customers/domain/usecases/update_customer_usecase.dart';
import '../../features/customers/presentation/cubit/customers/customers_cubit.dart';
import '../../features/customers/presentation/cubit/add_edit_customer/add_edit_customer_cubit.dart';
import '../../features/customers/presentation/cubit/customer_details/customer_details_cubit.dart';
import '../../features/invoice/data/datasources/invoice_remote_data_source.dart';
import '../../features/invoice/data/datasources/invoice_remote_data_source_impl.dart';
import '../../features/invoice/data/mappers/invoice_mapper.dart';
import '../../features/invoice/data/repositories/invoice_repository_impl.dart';
import '../../features/invoice/domain/repositories/invoice_repository.dart';
import '../../features/invoice/domain/services/discount_calculator.dart';
import '../../features/invoice/domain/usecases/add_payment_usecase.dart';
import '../../features/invoice/domain/usecases/cancel_invoice_usecase.dart';
import '../../features/invoice/domain/usecases/create_invoice_usecase.dart';
import '../../features/invoice/domain/usecases/get_invoice_usecase.dart';
import '../../features/invoice/domain/usecases/get_invoices_usecase.dart';
import '../../features/invoice/presentation/cubit/add_payment/add_payment_cubit.dart';
import '../../features/invoice/presentation/cubit/create_invoice/create_invoice_cubit.dart';
import '../../features/invoice/presentation/cubit/customer_picker/customer_picker_cubit.dart';
import '../../features/invoice/presentation/cubit/invoice_details/invoice_details_cubit.dart';
import '../../features/invoice/presentation/cubit/invoices/invoices_cubit.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_data_source_impl.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_sales_usecase.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator({SharedPreferences? prefs}) async {
  // Persisted theme / locale — single source, no hardcoded defaults
  SharedPreferences? sp = prefs;
  if (sp == null) {
    try {
      sp = await SharedPreferences.getInstance();
    } catch (_) {
      sp = null; // tests / unsupported platforms — fall back to in-memory
    }
  }
  if (sp != null) {
    sl.registerLazySingleton<SharedPreferences>(() => sp!);
    sl.registerLazySingleton<AppLocaleCubit>(() => AppLocaleCubit(prefs: sp));
  } else {
    sl.registerLazySingleton<AppLocaleCubit>(() => AppLocaleCubit());
  }
  // Core: Token storage + API client + file upload
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(tokenStorage: sl<TokenStorage>()),
  );
  sl.registerLazySingleton<FileUploadService>(
    () => FileUploadService(apiClient: sl<ApiClient>()),
  );

  // Auth: Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      apiClient: sl<ApiClient>(),
      tokenStorage: sl<TokenStorage>(),
    ),
  );

  // Auth: Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  // Auth: Use cases
  sl.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignInWithGoogleUseCase>(
    () => SignInWithGoogleUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifyEmailUseCase>(
    () => VerifyEmailUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ResendVerificationEmailUseCase>(
    () => ResendVerificationEmailUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<AuthStateChangesUseCase>(
    () => AuthStateChangesUseCase(sl<AuthRepository>()),
  );

  // Auth: Cubits
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      signInUseCase: sl<SignInUseCase>(),
      signInWithGoogleUseCase: sl<SignInWithGoogleUseCase>(),
      signUpUseCase: sl<SignUpUseCase>(),
      signOutUseCase: sl<SignOutUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
      authStateChangesUseCase: sl<AuthStateChangesUseCase>(),
      verifyEmailUseCase: sl<VerifyEmailUseCase>(),
      resendVerificationEmailUseCase: sl<ResendVerificationEmailUseCase>(),
    ),
  );

  // Products: Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Products: Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl<ProductRemoteDataSource>()),
  );

  // Products: Use cases
  sl.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(sl<ProductRepository>()),
  );

  sl.registerLazySingleton<CreateProductUseCase>(
    () => CreateProductUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<UploadProductImageUseCase>(
    () => UploadProductImageUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<GetProductUseCase>(
    () => GetProductUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<UpdateProductUseCase>(
    () => UpdateProductUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<DeleteProductUseCase>(
    () => DeleteProductUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<UpdateProductQuantityUseCase>(
    () => UpdateProductQuantityUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<GetInventoryMovementsUseCase>(
    () => GetInventoryMovementsUseCase(sl<ProductRepository>()),
  );

  // Products: Cubits
  sl.registerFactory<ProductsCubit>(
    () => ProductsCubit(getProductsUseCase: sl<GetProductsUseCase>()),
  );

  sl.registerFactory<AddEditProductCubit>(
    () => AddEditProductCubit(
      createProductUseCase: sl<CreateProductUseCase>(),
      uploadImageUseCase: sl<UploadProductImageUseCase>(),
      getProductUseCase: sl<GetProductUseCase>(),
      updateProductUseCase: sl<UpdateProductUseCase>(),
    ),
  );

  sl.registerFactory<ProductDetailsCubit>(
    () => ProductDetailsCubit(
      getProductUseCase: sl<GetProductUseCase>(),
      deleteProductUseCase: sl<DeleteProductUseCase>(),
      updateQuantityUseCase: sl<UpdateProductQuantityUseCase>(),
      getMovementsUseCase: sl<GetInventoryMovementsUseCase>(),
    ),
  );

  // Customers: Data sources
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Customers: Repositories
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(sl<CustomerRemoteDataSource>()),
  );

  // Customers: Use cases
  sl.registerLazySingleton<GetCustomersUseCase>(
    () => GetCustomersUseCase(sl<CustomerRepository>()),
  );
  sl.registerLazySingleton<GetCustomerFilterCountsUseCase>(
    () => GetCustomerFilterCountsUseCase(sl<CustomerRepository>()),
  );
  sl.registerLazySingleton<CreateCustomerUseCase>(
    () => CreateCustomerUseCase(sl<CustomerRepository>()),
  );
  sl.registerLazySingleton<UploadCustomerImageUseCase>(
    () => UploadCustomerImageUseCase(sl<CustomerRepository>()),
  );
  sl.registerLazySingleton<GetCustomerUseCase>(
    () => GetCustomerUseCase(sl<CustomerRepository>()),
  );
  sl.registerLazySingleton<UpdateCustomerUseCase>(
    () => UpdateCustomerUseCase(sl<CustomerRepository>()),
  );

  // Customers: Cubits
  sl.registerFactory<CustomersCubit>(
    () => CustomersCubit(
      getCustomersUseCase: sl<GetCustomersUseCase>(),
      getCustomerFilterCountsUseCase: sl<GetCustomerFilterCountsUseCase>(),
    ),
  );

  sl.registerFactory<AddEditCustomerCubit>(
    () => AddEditCustomerCubit(
      createCustomerUseCase: sl<CreateCustomerUseCase>(),
      uploadImageUseCase: sl<UploadCustomerImageUseCase>(),
      getCustomerUseCase: sl<GetCustomerUseCase>(),
      updateCustomerUseCase: sl<UpdateCustomerUseCase>(),
    ),
  );

  sl.registerFactory<CustomerDetailsCubit>(
    () => CustomerDetailsCubit(getCustomerUseCase: sl<GetCustomerUseCase>()),
  );

  // Invoice: Domain services (SRP — discount & mapping isolated)
  sl.registerLazySingleton<DiscountCalculator>(() => DiscountCalculatorImpl());
  sl.registerLazySingleton<InvoiceMapper>(() => InvoiceMapperImpl());

  // Invoice: Data sources
  sl.registerLazySingleton<InvoiceRemoteDataSource>(
    () => InvoiceRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Invoice: Repositories (DI — depends on abstractions DiscountCalculator/InvoiceMapper)
  sl.registerLazySingleton<InvoiceRepository>(
    () => InvoiceRepositoryImpl(
      sl<InvoiceRemoteDataSource>(),
      discountCalculator: sl<DiscountCalculator>(),
      invoiceMapper: sl<InvoiceMapper>(),
    ),
  );

  // Invoice: Use cases
  sl.registerLazySingleton<CreateInvoiceUseCase>(
    () => CreateInvoiceUseCase(sl<InvoiceRepository>()),
  );
  sl.registerLazySingleton<AddPaymentUseCase>(
    () => AddPaymentUseCase(sl<InvoiceRepository>()),
  );
  sl.registerLazySingleton<GetInvoiceUseCase>(
    () => GetInvoiceUseCase(sl<InvoiceRepository>()),
  );
  sl.registerLazySingleton<GetInvoicesUseCase>(
    () => GetInvoicesUseCase(sl<InvoiceRepository>()),
  );
  sl.registerLazySingleton<CancelInvoiceUseCase>(
    () => CancelInvoiceUseCase(sl<InvoiceRepository>()),
  );

  // Invoice: Cubits
  sl.registerFactory<CreateInvoiceCubit>(
    () => CreateInvoiceCubit(createInvoiceUseCase: sl<CreateInvoiceUseCase>()),
  );

  sl.registerFactory<InvoiceDetailsCubit>(
    () => InvoiceDetailsCubit(
      getInvoiceUseCase: sl<GetInvoiceUseCase>(),
      cancelInvoiceUseCase: sl<CancelInvoiceUseCase>(),
    ),
  );

  sl.registerFactory<InvoicesCubit>(
    () => InvoicesCubit(
      getInvoicesUseCase: sl<GetInvoicesUseCase>(),
      getCustomersUseCase: sl<GetCustomersUseCase>(),
    ),
  );

  sl.registerFactory<CustomerPickerCubit>(
    () => CustomerPickerCubit(
      getCustomersUseCase: sl<GetCustomersUseCase>(),
      companyId: '',
    ),
  );

  sl.registerFactory<AddPaymentCubit>(
    () => AddPaymentCubit(
      getInvoicesUseCase: sl<GetInvoicesUseCase>(),
      addPaymentUseCase: sl<AddPaymentUseCase>(),
    ),
  );

  // Companies: Data sources
  sl.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Companies: Repository
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(sl<CompanyRemoteDataSource>()),
  );

  // Companies: Use cases
  sl.registerLazySingleton<GetUserCompaniesUseCase>(
    () => GetUserCompaniesUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<CreateCompanyUseCase>(
    () => CreateCompanyUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<GetCompanyUseCase>(
    () => GetCompanyUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<UpdateCompanyUseCase>(
    () => UpdateCompanyUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<GetCompanyMembersUseCase>(
    () => GetCompanyMembersUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<InviteMemberUseCase>(
    () => InviteMemberUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<UpdateMemberPermissionsUseCase>(
    () => UpdateMemberPermissionsUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<RemoveMemberUseCase>(
    () => RemoveMemberUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<JoinCompanyByCodeUseCase>(
    () => JoinCompanyByCodeUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<ApproveJoinRequestUseCase>(
    () => ApproveJoinRequestUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<RejectJoinRequestUseCase>(
    () => RejectJoinRequestUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<GetJoinRequestsUseCase>(
    () => GetJoinRequestsUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<CheckJoinRequestStatusUseCase>(
    () => CheckJoinRequestStatusUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<CreateCompanyFullUseCase>(
    () => CreateCompanyFullUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<CancelJoinRequestUseCase>(
    () => CancelJoinRequestUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<GetCompanyJoinCodeUseCase>(
    () => GetCompanyJoinCodeUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<RegenerateCompanyJoinCodeUseCase>(
    () => RegenerateCompanyJoinCodeUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<DeactivateMemberUseCase>(
    () => DeactivateMemberUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<ReactivateMemberUseCase>(
    () => ReactivateMemberUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<RemoveCompanyMemberUseCase>(
    () => RemoveCompanyMemberUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<PromoteMemberToOwnerUseCase>(
    () => PromoteMemberToOwnerUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<DemoteOwnerToMemberUseCase>(
    () => DemoteOwnerToMemberUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<GetMemberPermissionsUseCase>(
    () => GetMemberPermissionsUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<LeaveCompanyUseCase>(
    () => LeaveCompanyUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<DeleteCompanyUseCase>(
    () => DeleteCompanyUseCase(sl<CompanyRepository>()),
  );

  // Join Company Cubit — must be a factory so each screen visit gets a fresh
  // instance; a singleton gets closed on screen dispose and crashes on re-entry.
  sl.registerFactory<JoinCompanyCubit>(
    () => JoinCompanyCubit(
      joinCompanyByCodeUseCase: sl<JoinCompanyByCodeUseCase>(),
      checkJoinRequestStatusUseCase: sl<CheckJoinRequestStatusUseCase>(),
      cancelJoinRequestUseCase: sl<CancelJoinRequestUseCase>(),
    ),
  );

  // Company Members Cubit
  sl.registerFactory<CompanyMembersCubit>(
    () => CompanyMembersCubit(
      getCompanyMembersUseCase: sl<GetCompanyMembersUseCase>(),
      inviteMemberUseCase: sl<InviteMemberUseCase>(),
      updateMemberPermissionsUseCase: sl<UpdateMemberPermissionsUseCase>(),
      removeMemberUseCase: sl<RemoveMemberUseCase>(),
      removeCompanyMemberUseCase: sl<RemoveCompanyMemberUseCase>(),
      deactivateMemberUseCase: sl<DeactivateMemberUseCase>(),
      reactivateMemberUseCase: sl<ReactivateMemberUseCase>(),
      promoteMemberToOwnerUseCase: sl<PromoteMemberToOwnerUseCase>(),
      demoteOwnerToMemberUseCase: sl<DemoteOwnerToMemberUseCase>(),
      getMemberPermissionsUseCase: sl<GetMemberPermissionsUseCase>(),
    ),
  );

  // Company Settings Cubit — uses FileUploadService (SRP)
  sl.registerFactory<CompanySettingsCubit>(
    () => CompanySettingsCubit(
      updateCompanyUseCase: sl<UpdateCompanyUseCase>(),
      getCompanyJoinCodeUseCase: sl<GetCompanyJoinCodeUseCase>(),
      regenerateCompanyJoinCodeUseCase: sl<RegenerateCompanyJoinCodeUseCase>(),
      leaveCompanyUseCase: sl<LeaveCompanyUseCase>(),
      deleteCompanyUseCase: sl<DeleteCompanyUseCase>(),
      fileUploadService: sl<FileUploadService>(),
    ),
  );

  // Permission Service
  sl.registerLazySingleton<PermissionService>(() => PermissionServiceImpl());

  // Company Cubit
  sl.registerLazySingleton<CompanyCubit>(
    () => CompanyCubit(
      getUserCompaniesUseCase: sl<GetUserCompaniesUseCase>(),
      secureStorage: const FlutterSecureStorage(),
    ),
  );

  // Dashboard: Data sources — REST via ApiClient
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Dashboard: Repositories
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl<DashboardRemoteDataSource>()),
  );

  // Dashboard: Use cases
  sl.registerLazySingleton<GetDashboardStatsUseCase>(
    () => GetDashboardStatsUseCase(sl<DashboardRepository>()),
  );
  sl.registerLazySingleton<GetDashboardSalesUseCase>(
    () => GetDashboardSalesUseCase(sl<DashboardRepository>()),
  );

  // Dashboard: Cubits
  sl.registerFactory<DashboardCubit>(
    () => DashboardCubit(
      getDashboardStatsUseCase: sl<GetDashboardStatsUseCase>(),
      getDashboardSalesUseCase: sl<GetDashboardSalesUseCase>(),
    ),
  );
}
