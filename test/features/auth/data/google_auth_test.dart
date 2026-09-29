import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/core/constants/api_endpoints.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/features/auth/data/models/user_model.dart';

void main() {
  test('google endpoint wiring: Dio path + base URL = backend route', () {
    // MakhzanFlowEnv.apiBaseUrl ends with /api, so this Dio path produces
    // the backend route POST {host}/api/auth/google — no double /api prefix.
    expect(ApiEndpoints.google, '/auth/google');
  });
  group('UserModel google fields', () {
    test('parses avatar_url and auth_provider', () {
      final user = UserModel.fromJson({
        'id': 'u1',
        'email': 'a@gmail.com',
        'name': 'A',
        'is_verified': true,
        'avatar_url': 'https://pic',
        'auth_provider': 'google',
      });
      expect(user.avatarUrl, 'https://pic');
      expect(user.authProvider, 'google');
    });

    test('null-safe for email users + round-trips offline snapshot', () {
      final user = UserModel.fromJson({'id': 'u1', 'email': 'a@x.com'});
      expect(user.avatarUrl, isNull);
      expect(user.authProvider, isNull);
      final restored = UserModel.fromJson(user.toJson());
      expect(restored.id, 'u1');
      expect(restored.avatarUrl, isNull);
    });
  });

  group('googleAuthErrorMessage', () {
    test('maps useGoogleSignIn marker to friendly hint', () {
      expect(
        AppStrings.googleAuthErrorMessage('401 errors.useGoogleSignIn'),
        AppStrings.useGoogleSignIn,
      );
    });

    test('maps real backend wordings (en + ar) to friendly hints', () {
      // Exact strings from backend locales/{en,ar}/auth.json — the envelope
      // carries translated text only, no messageKey.
      expect(
        AppStrings.googleAuthErrorMessage(
            'This account uses Google sign-in. Please continue with Google.'),
        AppStrings.useGoogleSignIn,
      );
      expect(
        AppStrings.googleAuthErrorMessage(
            'هذا الحساب يستخدم تسجيل الدخول عبر Google. يرجى المتابعة عبر Google.'),
        AppStrings.useGoogleSignIn,
      );
      expect(
        AppStrings.googleAuthErrorMessage('Google email is not verified'),
        AppStrings.googleEmailNotVerified,
      );
      expect(
        AppStrings.googleAuthErrorMessage(
            'البريد الإلكتروني في Google غير مؤكد'),
        AppStrings.googleEmailNotVerified,
      );
    });

    test('passes unrelated messages through', () {
      expect(AppStrings.googleAuthErrorMessage('wrong password'), 'wrong password');
    });
  });
}
