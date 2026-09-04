import 'package:makhzanflow/features/companies/domain/entities/company_member.dart';

class CompanyMemberModel extends CompanyMember {
  const CompanyMemberModel({
    required super.id,
    required super.companyId,
    required super.userId,
    required super.isOwner,
    required super.permissions,
    required super.joinedAt,
    super.userName,
    super.userEmail,
    super.status,
    super.deactivatedAt,
    super.deactivatedBy,
    super.removedAt,
    super.removedBy,
  });

  factory CompanyMemberModel.fromJson(Map<String, dynamic> json) {
    final users = json['users'] as Map<String, dynamic>?;
    final role = json['role'] as String?;
    final joinedAt = json['joined_at'] as String? ?? json['created_at'] as String?;
    return CompanyMemberModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      isOwner: json['is_owner'] as bool? ?? role == 'owner',
      permissions: json['permissions'] != null
          ? Map<String, dynamic>.from(json['permissions'] as Map)
          : const {},
      joinedAt: joinedAt != null
          ? DateTime.parse(joinedAt)
          : DateTime.now(),
      userName: json['user_name'] as String? ?? users?['name'] as String?,
      userEmail: json['user_email'] as String? ?? users?['email'] as String?,
      status: json['status'] as String? ?? 'active',
      deactivatedAt: json['deactivated_at'] != null
          ? DateTime.parse(json['deactivated_at'] as String)
          : null,
      deactivatedBy: json['deactivated_by'] as String?,
      removedAt: json['removed_at'] != null
          ? DateTime.parse(json['removed_at'] as String)
          : null,
      removedBy: json['removed_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'company_id': companyId,
    'user_id': userId,
    'is_owner': isOwner,
    'permissions': permissions,
    'joined_at': joinedAt.toIso8601String(),
    'status': status,
  };
}
