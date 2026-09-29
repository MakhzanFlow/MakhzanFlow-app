import 'package:flutter/material.dart';

/// Shared staggered entrance for dashboard surfaces.
///
/// ui-skills (better-ui / interface-design):
/// - Animates compositor props only (`opacity` + `offset`) with `easeOut`.
/// - Staggers infrequent entrances ~60ms apart (30–80ms recipe range).
/// - Respects `prefers-reduced-motion` via [MediaQuery.disableAnimations].
class MFEntrance extends StatefulWidget {
  const MFEntrance({super.key, required this.index, required this.child});

  /// Zero-based position in the entrance sequence.
  final int index;
  final Widget child;

  @override
  State<MFEntrance> createState() => _MFEntranceState();
}

class _MFEntranceState extends State<MFEntrance> {
  bool _visible = false;
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inherited widgets (MediaQuery) are readable here, unlike initState.
    if (_scheduled) return;
    _scheduled = true;
    if (MediaQuery.maybeDisableAnimationsOf(context) == true) {
      _visible = true;
      return;
    }
    final delay = Duration(milliseconds: (widget.index * 60).clamp(0, 300));
    if (delay == Duration.zero) {
      _visible = true;
      return;
    }
    Future.delayed(delay).then((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) == true) {
      return widget.child;
    }
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        offset: _visible ? Offset.zero : const Offset(0, 0.06),
        child: widget.child,
      ),
    );
  }
}
