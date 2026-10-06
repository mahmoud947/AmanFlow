import 'package:flutter/material.dart';

IconData iconForCategory(String category) {
  switch (category) {
    case 'recharge':
    case 'telecom':
      return Icons.smartphone_rounded;
    case 'electricity':
      return Icons.bolt_rounded;
    case 'internet':
      return Icons.wifi_rounded;
    case 'water':
      return Icons.water_drop_rounded;
    case 'gas':
      return Icons.local_fire_department_rounded;
    case 'donations':
      return Icons.volunteer_activism_rounded;
    case 'transfer':
      return Icons.swap_horiz_rounded;
    case 'cashback':
      return Icons.card_giftcard_rounded;
    default:
      return Icons.receipt_long_rounded;
  }
}
