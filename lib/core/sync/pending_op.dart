import 'package:equatable/equatable.dart';
import 'package:makhzanflow/core/constants/app_constants.dart';

/// Mutation kinds the offline queue can replay.
/// Gated kinds (pricing/stock/payment/cancel) MUST carry `version` in [PendingOp.body];
/// LWW kinds never send it (see docs/flutter-conflict-resolution.md §1).
enum PendingOpType {
  productPricing,
  stockAdjust,
  invoicePayment,
  invoiceCancel,
  customerUpdate,
  productMetadata,
  productCreate,
  customerCreate,
  invoiceCreate,
  productDelete;

  /// Gated (optimistic-locking) writes — server decides order by `version`.
  bool get isGated => switch (this) {
        productPricing || stockAdjust || invoicePayment || invoiceCancel => true,
        customerUpdate ||
        productMetadata ||
        productCreate ||
        customerCreate ||
        invoiceCreate ||
        productDelete =>
          false,
      };

  /// Only these kinds may enter the offline queue (add-new-only policy for
  /// products/customers + stock movement; everything else needs connectivity).
  /// Money-moving kinds (invoicePayment/Cancel/Create, productPricing) are
  /// therefore online-only by construction.
  bool get isQueueableOffline => switch (this) {
        productCreate || customerCreate || stockAdjust || productDelete =>
          true,
        _ => false,
      };

  static PendingOpType fromName(String name) =>
      PendingOpType.values.byName(name);
}

/// A local mutation waiting for replay. Auth headers (`x-company-id`, JWT) are
/// injected at replay time and MUST never be persisted here.
class PendingOp extends Equatable {
  final String id;
  final DateTime createdAt;
  final PendingOpType opType;
  final String method;
  final String path;
  final Map<String, dynamic> body;
  final String companyId;
  final int attempts;
  /// Local image picked for a create op — uploaded after the create replays
  /// (binaries never travel inside [body]).
  final String? imageLocalPath;

  static int _seq = 0;

  const PendingOp({
    required this.id,
    required this.createdAt,
    required this.opType,
    required this.method,
    required this.path,
    required this.body,
    required this.companyId,
    this.attempts = 0,
    this.imageLocalPath,
  });

  /// Creates an op with a generated unique id and current UTC timestamp.
  /// The id carries [AppConstants.pendingIdPrefix] so optimistic entities
  /// built from it are recognizable as unsynced until replay succeeds.
  factory PendingOp.createNew({
    required PendingOpType opType,
    required String method,
    required String path,
    required Map<String, dynamic> body,
    required String companyId,
    String? imageLocalPath,
  }) {
    final now = DateTime.now().toUtc();
    return PendingOp(
      id: '${AppConstants.pendingIdPrefix}'
          '${now.microsecondsSinceEpoch}-${_seq++}',
      createdAt: now,
      opType: opType,
      method: method,
      path: path,
      body: body,
      companyId: companyId,
      imageLocalPath: imageLocalPath,
    );
  }

  PendingOp withAttempt() => PendingOp(
        id: id,
        createdAt: createdAt,
        opType: opType,
        method: method,
        path: path,
        body: body,
        companyId: companyId,
        attempts: attempts + 1,
      );

  factory PendingOp.fromJson(Map<String, dynamic> json) => PendingOp(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        opType: PendingOpType.fromName(json['opType'] as String),
        method: json['method'] as String,
        path: json['path'] as String,
        body: Map<String, dynamic>.from(json['body'] as Map),
        companyId: json['companyId'] as String,
        attempts: (json['attempts'] as num?)?.toInt() ?? 0,
        imageLocalPath: json['imageLocalPath'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'opType': opType.name,
        'method': method,
        'path': path,
        'body': body,
        'companyId': companyId,
        'attempts': attempts,
        if (imageLocalPath != null) 'imageLocalPath': imageLocalPath,
      };

  @override
  List<Object?> get props => [
        id,
        createdAt,
        opType,
        method,
        path,
        body,
        companyId,
        attempts,
        imageLocalPath,
      ];
}

/// A replayed op that hit `409 VERSION_CONFLICT`, parked for operator review.
/// Finance/stock conflicts are never auto-resolved.
class NeedsReviewOp extends Equatable {
  final PendingOp base;
  final Map<String, dynamic> current;
  final Map<String, dynamic> attempted;
  final DateTime conflictedAt;
  final String entity;
  final String entityId;

  const NeedsReviewOp({
    required this.base,
    required this.current,
    required this.attempted,
    required this.conflictedAt,
    required this.entity,
    required this.entityId,
  });

  factory NeedsReviewOp.fromJson(Map<String, dynamic> json) => NeedsReviewOp(
        base: PendingOp.fromJson(Map<String, dynamic>.from(json['base'] as Map)),
        current: Map<String, dynamic>.from(json['current'] as Map),
        attempted: Map<String, dynamic>.from(json['attempted'] as Map),
        conflictedAt: DateTime.parse(json['conflictedAt'] as String),
        entity: json['entity'] as String? ?? 'record',
        entityId: json['entityId'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'base': base.toJson(),
        'current': current,
        'attempted': attempted,
        'conflictedAt': conflictedAt.toIso8601String(),
        'entity': entity,
        'entityId': entityId,
      };

  @override
  List<Object?> get props =>
      [base, current, attempted, conflictedAt, entity, entityId];
}
