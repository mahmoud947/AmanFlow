import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Floating pill navigation bar.
class AppBottomNavigation extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const AppBottomNavigation({
    super.key,
    required this.index,
    required this.onChanged,
  });

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.payments_outlined, Icons.payments_rounded, 'Payments'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(34),
                    onTap: () => onChanged(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          index == i ? _items[i].$2 : _items[i].$1,
                          color: index == i
                              ? AppColors.primary
                              : AppColors.muted,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _items[i].$3,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: index == i
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: index == i
                                ? AppColors.primary
                                : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
