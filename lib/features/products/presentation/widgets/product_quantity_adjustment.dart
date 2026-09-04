import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class ProductQuantityAdjustment extends StatefulWidget {
  final int currentQuantity;
  final bool isLoading;
  final ValueChanged<int> onAdjust;
  final ValueChanged<String> onNoteChanged;

  const ProductQuantityAdjustment({
    super.key,
    required this.currentQuantity,
    this.isLoading = false,
    required this.onAdjust,
    required this.onNoteChanged,
  });

  @override
  State<ProductQuantityAdjustment> createState() =>
      _ProductQuantityAdjustmentState();
}

class _ProductQuantityAdjustmentState
    extends State<ProductQuantityAdjustment> {
  int _delta = 0;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MFTokens.sp16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.productQuantityUpdate,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MFTokens.fontLG,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: MFTokens.sp8),
            Text(
              '${AppStrings.productQuantityLabel}: ${widget.currentQuantity}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MFTokens.fontMD,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: MFTokens.sp16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.isLoading
                        ? null
                        : () {
                            setState(() => _delta = -1);
                          },
                    icon: const Icon(Icons.remove),
                    label: Text(
                      '${AppStrings.productQuantityOut} (${_delta < 0 ? -_delta : 0})',
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ),
                const SizedBox(width: MFTokens.sp8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.isLoading
                        ? null
                        : () {
                            setState(() => _delta = 1);
                          },
                    icon: const Icon(Icons.add),
                    label: Text(
                      '${AppStrings.productQuantityIn} (${_delta > 0 ? _delta : 0})',
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: MFTokens.sp8),
            Row(
              children: [
                _qtyButton('-10', () => _updateDelta(-10)),
                _qtyButton('-5', () => _updateDelta(-5)),
                _qtyButton('-1', () => _updateDelta(-1)),
                _qtyButton('+1', () => _updateDelta(1)),
                _qtyButton('+5', () => _updateDelta(5)),
                _qtyButton('+10', () => _updateDelta(10)),
              ],
            ),
            const SizedBox(height: MFTokens.sp8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: AppStrings.productQuantityNote,
                hintText: AppStrings.productQuantityNote,
              ),
              textDirection: TextDirection.rtl,
              onChanged: widget.onNoteChanged,
            ),
            const SizedBox(height: MFTokens.sp16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _delta == 0 || widget.isLoading
                    ? null
                    : () => widget.onAdjust(_delta),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        '${AppStrings.productQuantityUpdate} (${_delta > 0 ? "+$_delta" : _delta})',
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(String label, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: MFTokens.fontXS,
            ),
          ),
        ),
      ),
    );
  }

  void _updateDelta(int amount) {
    setState(() {
      final next = _delta + amount;
      final newQty = widget.currentQuantity + next;
      if (newQty >= 0) {
        _delta = next;
      }
    });
  }
}
