import 'package:flutter/material.dart';
import 'package:ipotapp/utils/color_utils.dart';

/// Orders tab body (used inside [AppShellScreen] [IndexedStack]).
class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Orders',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.neutral,
        ),
      ),
    );
  }
}
