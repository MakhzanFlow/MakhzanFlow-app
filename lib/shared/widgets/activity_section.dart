import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:makhzanflow/core/activity/activity_log_data_source.dart';
import 'package:makhzanflow/core/activity/activity_log_entry.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/di/service_locator.dart';
import 'package:makhzanflow/core/permissions/permission_gate.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';

/// Collapsible audit-trail section for record detail screens
/// (product / invoice / customer). Loads lazily on first expand.
class ActivitySection extends StatefulWidget {
  final ActivityLogEntity entity;
  final String entityId;
  final String readPermission;

  const ActivitySection({
    super.key,
    required this.entity,
    required this.entityId,
    required this.readPermission,
  });

  @override
  State<ActivitySection> createState() => _ActivitySectionState();
}

class _ActivitySectionState extends State<ActivitySection> {
  bool _loaded = false;
  bool _loading = false;
  String? _error;
  List<ActivityLogEntry> _entries = [];

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await sl<ActivityLogDataSource>().getLogs(
      entity: widget.entity,
      entityId: widget.entityId,
    );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (entries) => setState(() {
        _loading = false;
        _loaded = true;
        _entries = entries;
      }),
    );
  }

  void _onExpanded(bool expanded) {
    if (expanded && !_loaded && !_loading) _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;
    final textPrimary =
        isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary =
        isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return PermissionGate(
      permission: widget.readPermission,
      child: Card(
        color: cardBg,
        margin: EdgeInsets.zero,
        child: ExpansionTile(
          onExpansionChanged: _onExpanded,
          leading: const Icon(Icons.history_outlined),
          title: Text(
            AppStrings.activityTitle,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          children: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(MFTokens.sp16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(MFTokens.sp16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(_error!,
                          style: TextStyle(
                              fontFamily: 'Cairo', color: textSecondary)),
                    ),
                    TextButton(
                      onPressed: _load,
                      child: Text(AppStrings.retry),
                    ),
                  ],
                ),
              )
            else if (_entries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(MFTokens.sp16),
                child: Text(
                  AppStrings.activityEmpty,
                  style:
                      TextStyle(fontFamily: 'Cairo', color: textSecondary),
                ),
              )
            else
              ..._entries.map(
                (e) => ListTile(
                  dense: true,
                  leading: Icon(
                    _iconFor(e.action),
                    size: 18,
                    color: isDark
                        ? MFTokens.primaryDarkMode
                        : MFTokens.primary,
                  ),
                  title: Text(
                    _labelFor(e.action),
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: textPrimary),
                  ),
                  subtitle: e.createdAt != null
                      ? Text(
                          DateFormat('yyyy-MM-dd HH:mm')
                              .format(e.createdAt!.toLocal()),
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: textSecondary),
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String action) {
    switch (action) {
      case 'create':
        return Icons.add_circle_outline;
      case 'update':
        return Icons.edit_outlined;
      case 'delete':
      case 'cancel':
        return Icons.cancel_outlined;
      default:
        return Icons.fiber_manual_record;
    }
  }

  String _labelFor(String action) {
    switch (action) {
      case 'create':
        return AppStrings.activityCreated;
      case 'update':
        return AppStrings.activityUpdated;
      case 'delete':
        return AppStrings.activityDeleted;
      case 'cancel':
        return AppStrings.activityCanceled;
      default:
        return action;
    }
  }
}
