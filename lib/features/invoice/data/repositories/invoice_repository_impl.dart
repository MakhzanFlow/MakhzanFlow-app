import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/constants/error_messages.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/invoice/data/datasources/invoice_remote_data_source.dart';
import 'package:makhzanflow/features/invoice/data/mappers/invoice_mapper.dart';
import 'package:makhzanflow/features/invoice/data/models/add_payment_dto.dart';
import 'package:makhzanflow/features/invoice/data/models/invoice_create_dto.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice.dart';
import 'package:makhzanflow/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:makhzanflow/features/invoice/domain/services/discount_calculator.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource dataSource;
  final DiscountCalculator discountCalculator;
  final InvoiceMapper invoiceMapper;

  InvoiceRepositoryImpl(
    this.dataSource, {
    DiscountCalculator? discountCalculator,
    InvoiceMapper? invoiceMapper,
  }) : discountCalculator = discountCalculator ?? DiscountCalculatorImpl(),
       invoiceMapper = invoiceMapper ?? InvoiceMapperImpl();

  @override
  Future<Either<Failure, String>> createInvoice({
    required String customerId,
    required List<Map<String, dynamic>> items,
    double? discountAmount,
    double? taxAmount,
    String? dueDate,
    double paidNow = 0,
    String paymentMethod = 'cash',
    String discountType = 'fixed',
    double discountValue = 0,
    String? referenceNumber,
    String? notes,
  }) async {
    if (customerId.trim().isEmpty) {
      return Left(ValidationFailure(ErrorMessages.selectCustomer));
    }

    final itemResult = invoiceMapper.toItemDtos(items);
    if (itemResult.isLeft()) {
      return Left(itemResult.getLeft().toNullable()!);
    }
    final itemDtos = itemResult.getOrElse((_) => []);

    final effectiveDiscount = discountCalculator.calculate(
      explicitAmount: discountAmount,
      discountType: discountType,
      discountValue: discountValue,
      items: items,
    );
    final effectiveTax = taxAmount ?? 0;

    final paymentResult = invoiceMapper.toPayment(
      paidNow: paidNow,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes,
    );
    if (paymentResult.isLeft()) {
      return Left(paymentResult.getLeft().toNullable()!);
    }
    final payment = paymentResult.getOrElse((_) => null);

    final dto = InvoiceCreateDto(
      customerId: customerId,
      discountAmount: effectiveDiscount,
      taxAmount: effectiveTax,
      dueDate: dueDate,
      items: itemDtos,
      payment: payment,
    );

    final result = await dataSource.createInvoice(dto);
    return result.map((model) => model.id);
  }

  @override
  Future<Either<Failure, String>> addPayment({
    required String invoiceId,
    required double amount,
    String method = 'cash',
    String? referenceNumber,
    String? notes,
  }) async {
    if (invoiceId.trim().isEmpty)
      return Left(ValidationFailure(ErrorMessages.selectInvoice));
    if (amount <= 0)
      return Left(ValidationFailure(ErrorMessages.invalidAmount));
    final dto = AddPaymentDto(
      invoiceId: invoiceId,
      amount: amount,
      method: method,
      referenceNumber: referenceNumber,
      notes: notes,
    );
    final result = await dataSource.addPayment(dto);
    return result.map((model) => model.id);
  }

  @override
  Future<Either<Failure, Invoice>> getInvoice(
    String id,
    String companyId,
  ) async {
    final result = await dataSource.getInvoice(id, companyId);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, List<Invoice>>> getInvoices({
    required String companyId,
    List<String>? statusFilter,
    String? customerId,
    int? limit,
    int? offset,
  }) async {
    final result = await dataSource.getInvoices(
      companyId: companyId,
      statusFilter: statusFilter,
      customerId: customerId,
      limit: limit,
      offset: offset,
    );
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, Invoice>> cancelInvoice(
    String id,
    String companyId,
  ) async {
    final result = await dataSource.cancelInvoice(id, companyId);
    return result.map((model) => model.toEntity());
  }
}
