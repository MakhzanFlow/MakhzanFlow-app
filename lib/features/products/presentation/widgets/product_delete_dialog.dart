import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final String? confirmLabel;
  final String? cancelLabel;

  const DeleteConfirmationDialog({
    super.key,
    this.title,
    this.message,
    this.confirmLabel,
    this.cancelLabel,
  });

  static Future<bool?> show(BuildContext context, {
    String? title,
    String? message,
    String? confirmLabel,
    String? cancelLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        title: title ?? AppStrings.productDelete,
        message: message ?? AppStrings.productDeleteConfirm,
        confirmLabel: confirmLabel ?? AppStrings.productDelete,
        cancelLabel: cancelLabel ?? AppStrings.productCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = isDark ? MFTokens.errorTextDark : MFTokens.errorText;

    return AlertDialog(
      title: Text(title ?? AppStrings.productDelete),
      content: Text(message ?? AppStrings.productDeleteConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel ?? AppStrings.productCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmLabel ?? AppStrings.productDelete,
            style: TextStyle(color: errorColor),
          ),
        ),
      ],
    );
  }
}
