import 'user_model.dart';

/// Response body for `POST /auth/login` and `POST /auth/verify-email`:
/// `{ accessToken, refreshToken, user }`
class AuthResponseDto {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}