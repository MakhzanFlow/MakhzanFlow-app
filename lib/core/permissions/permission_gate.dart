import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/company/company_cubit.dart';
import 'package:makhzanflow/core/company/company_state.dart';
import 'package:makhzanflow/core/di/service_locator.dart';
import 'package:makhzanflow/core/permissions/permission_service.dart';

class PermissionGate extends StatefulWidget {
  final String? permission;
  final List<String>? anyPermissions;
  final List<String>? allPermissions;
  final Widget child;
  final Widget? fallback;

  const PermissionGate({
    super.key,
    this.permission,
    this.anyPermissions,
    this.allPermissions,
    required this.child,
    this.fallback,
  });

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  StreamSubscription<CompanyState>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant PermissionGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.permission != widget.permission ||
        !listEquals(oldWidget.anyPermissions, widget.anyPermissions) ||
        !listEquals(oldWidget.allPermissions, widget.allPermissions)) {
      setState(() {});
    }
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = context.read<CompanyCubit>().stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permissionService = sl<PermissionService>();

    bool hasAccess;
    if (widget.permission != null) {
      hasAccess = permissionService.hasPermission(widget.permission!);
    } else if (widget.anyPermissions != null) {
      hasAccess = permissionService.hasAnyPermission(widget.anyPermissions!);
    } else if (widget.allPermissions != null) {
      hasAccess = permissionService.hasAllPermissions(widget.allPermissions!);
    } else {
      hasAccess = true;
    }

    if (hasAccess) return widget.child;
    return widget.fallback ?? const SizedBox.shrink();
  }
}
