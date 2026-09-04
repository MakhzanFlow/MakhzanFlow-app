import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/theme/mf_tokens.dart';

class CustomerLoadingView extends StatelessWidget {
  const CustomerLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SpinKitFadingCircle(
        size: 40,
        color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
      ),
    );
  }
}
