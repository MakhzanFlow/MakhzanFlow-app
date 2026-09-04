import 'package:makhzanflow/features/auth/domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final email = json['email'] as String? ?? '';
    return UserModel(
      id: json['id'] as String? ?? '',
      email: email,
      name: json['name'] as String? ?? email.split('@').first,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}
