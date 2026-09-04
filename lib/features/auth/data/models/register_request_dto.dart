/// Request body for `POST /auth/register`: `{ name, email, password }`
class RegisterRequestDto {
  final String name;
  final String email;
  final String password;

  const RegisterRequestDto({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };
}