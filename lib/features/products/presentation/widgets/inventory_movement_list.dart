import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/inventory_movement.dart';

class InventoryMovementList extends StatelessWidget {
  final List<InventoryMovement> movements;

  const InventoryMovementList({super.key, required this.movements});

  @override
  Widget build(BuildContext context) {
    if (movements.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.productMovementHistory,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.fontLG,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: MFTokens.sp8),
        ...movements.take(10).map((movement) {
          return Card(
            margin: const EdgeInsets.only(bottom: MFTokens.sp4),
            child: ListTile(
              dense: true,
              leading: Icon(
                movement.isIn
                    ? Icons.add_circle_outline
                    : Icons.remove_circle_outline,
                color: movement.isIn
                    ? MFTokens.successText
                    : (isDark ? MFTokens.errorTextDark : MFTokens.errorText),
              ),
              title: Text(
                '${movement.isIn ? AppStrings.productQuantityIn : AppStrings.productQuantityOut}: ${movement.quantity}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontSM,
                ),
              ),
              subtitle: movement.note != null
                  ? Text(
                      movement.note!,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: MFTokens.fontXS,
                      ),
                    )
                  : null,
            ),
          );
        }),
      ],
    );
  }
}
