import 'package:flutter/material.dart';

class NavigationDestinationData {
  final String route;
  final String labelAr;
  final String labelEn;
  final String semanticLabelAr;
  final IconData icon;
  final bool isCenterAction;
  final int sortOrderRtl;

  const NavigationDestinationData({
    required this.route,
    required this.labelAr,
    this.labelEn = '',
    required this.semanticLabelAr,
    required this.icon,
    this.isCenterAction = false,
    required this.sortOrderRtl,
  });

  String label(bool isArabic) => isArabic ? labelAr : (labelEn.isEmpty ? labelAr : labelEn);
}
