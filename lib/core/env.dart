import 'package:flutter_dotenv/flutter_dotenv.dart';

class MakhzanFlowEnv {
  static String get apiBaseUrl {
    final value = dotenv.env['API_BASE_URL']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('Missing API_BASE_URL in .env');
    }
    return value.replaceAll(RegExp(r'/+$'), '');
  }

  static String get sentryDsn {
    final value = dotenv.env['SENTRY_DSN']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('Missing SENTRY_DSN in .env');
    }
    return value;
  }

  static String get googleWebClientId {
    final value = dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('Missing GOOGLE_WEB_CLIENT_ID in .env');
    }
    return value;
  }
}
