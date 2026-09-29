import 'package:equatable/equatable.dart';

/// One audit-trail row from `GET /api/activity-logs/:entity/:entityId`.
/// `:entity` ∈ `product`, `invoice`, `customer`.
class ActivityLogEntry extends Equatable {
  final String id;
  final String entity;
  final String entityId;
  final String action;
  final Map<String, dynamic>? changes;
  final DateTime? createdAt;

  const ActivityLogEntry({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.action,
    this.changes,
    this.createdAt,
  });

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    DateTime? createdAt;
    for (final key in ['created_at', 'createdAt', 'timestamp']) {
      final raw = json[key];
      if (raw is String && raw.isNotEmpty) {
        createdAt = DateTime.tryParse(raw);
        if (createdAt != null) break;
      }
    }
    Map<String, dynamic>? changes;
    final rawChanges = json['changes'];
    if (rawChanges is Map<String, dynamic>) {
      changes = rawChanges;
    } else if (rawChanges is Map) {
      changes = Map<String, dynamic>.from(rawChanges);
    }
    return ActivityLogEntry(
      id: json['id']?.toString() ?? '',
      entity: json['entity']?.toString() ?? '',
      entityId: json['entity_id']?.toString() ??
          json['entityId']?.toString() ??
          '',
      action: json['action']?.toString() ?? '',
      changes: changes,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, entity, entityId, action, changes, createdAt];
}

/// Backend entity segment per record type.
enum ActivityLogEntity {
  product('product'),
  invoice('invoice'),
  customer('customer');

  final String segment;
  const ActivityLogEntity(this.segment);
}
