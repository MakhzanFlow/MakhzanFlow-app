import 'package:flutter/material.dart';
import '../theme/mf_tokens.dart';

class AppSnackbar {
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(context, message, MFTokens.primary, duration);
  }

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(context, message, MFTokens.errorText, duration);
  }

  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(context, message, MFTokens.successText, duration);
  }

  static void _show(
    BuildContext context,
    String message,
    Color backgroundColor,
    Duration duration,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
