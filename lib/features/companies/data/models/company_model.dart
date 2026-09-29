import 'package:makhzanflow/features/companies/domain/entities/company.dart';

class CompanyModel extends Company {
  const CompanyModel({
    required super.id,
    required super.name,
    super.address,
    super.phone,
    super.subscriptionPlan,
    super.subscriptionPlanName,
    super.status,
    super.businessType,
    super.logoUrl,
    super.inviteCode,
    required super.createdAt,
    super.updatedAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: (json['company_id'] ?? json['id']) as String,
      name: (json['company_name'] ?? json['name']) as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      subscriptionPlan: json['subscription_plan_id']?.toString() ?? 'free',
      subscriptionPlanName: json['subscription_plan_name'] as String?,
      status: json['status'] as String? ?? 'active',
      businessType: json['business_type'] as String?,
      logoUrl: json['logo_url'] as String?,
      inviteCode: json['invite_code'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  factory CompanyModel.fromEntity(Company entity) {
    return CompanyModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      phone: entity.phone,
      subscriptionPlan: entity.subscriptionPlan,
      subscriptionPlanName: entity.subscriptionPlanName,
      status: entity.status,
      businessType: entity.businessType,
      logoUrl: entity.logoUrl,
      inviteCode: entity.inviteCode,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'phone': phone,
    'subscription_plan_id': subscriptionPlan,
    'subscription_plan_name': subscriptionPlanName,
    'status': status,
    'business_type': businessType,
    'logo_url': logoUrl,
    'invite_code': inviteCode,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
