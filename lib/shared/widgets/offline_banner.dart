import 'dart:async';

import 'package:flutter/material.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/di/service_locator.dart';
import 'package:makhzanflow/core/sync/connectivity_monitor.dart';

/// Slim global banner shown while offline (reads are served from cache).
/// Overlays content via Stack — never disturbs layout. Hidden when the
/// connectivity monitor isn't registered (tests / unsupported platforms).
class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  StreamSubscription<bool>? _subscription;
  bool _online = true;

  @override
  void initState() {
    super.initState();
    if (!sl.isRegistered<ConnectivityMonitor>()) return;
    final monitor = sl<ConnectivityMonitor>();
    monitor.isOnline.then((online) {
      if (mounted) setState(() => _online = online);
    });
    _subscription = monitor.onStatusChanged.listen((online) {
      if (mounted) setState(() => _online = online);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_online) return widget.child;
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: AppSizes.spacingTiny,
                horizontal: AppSizes.spacingMedium,
              ),
              color: AppColors.lightOrange,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_outlined,
                    size: AppSizes.iconSmall,
                    color: AppColors.accent,
                  ),
                  SizedBox(width: AppSizes.spacingTiny),
                  Text(
                    AppStrings.offlineMode,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: AppSizes.fontSmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
