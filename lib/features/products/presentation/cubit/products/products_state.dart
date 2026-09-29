import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_filter.dart';

enum ProductsStatus { initial, loading, success, empty, error }

class ProductsState extends Equatable {
  final ProductsStatus status;
  final List<Product> products;
  final ProductFilter filter;
  final String? errorMessage;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;
  /// Ids of optimistic (unsynced) creates prepended from the offline queue.
  final Set<String> pendingIds;

  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.filter = const ProductFilter(),
    this.errorMessage,
    this.totalCount = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.pendingIds = const {},
  });

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    ProductFilter? filter,
    String? errorMessage,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
    Set<String>? pendingIds,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      pendingIds: pendingIds ?? this.pendingIds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    filter,
    errorMessage,
    totalCount,
    hasMore,
    isLoadingMore,
    pendingIds,
  ];
}
