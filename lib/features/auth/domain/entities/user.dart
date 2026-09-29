import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final bool isVerified;
  /// Google profile picture URL; null for most email users.
  final String? avatarUrl;
  /// 'email' | 'google' | 'email+google' (backend-driven, nullable-safe).
  final String? authProvider;

  const UserEntity({
    required this.id,
    required this.email,
    this.name = '',
    this.isVerified = false,
    this.avatarUrl,
    this.authProvider,
  });

  @override
  List<Object?> get props => [id, email, name, isVerified, avatarUrl, authProvider];
}
