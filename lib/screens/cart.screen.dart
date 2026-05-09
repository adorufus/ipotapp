import 'package:flutter/material.dart';
import 'package:ipotapp/utils/color_utils.dart';

/// Cart tab body (used inside [AppShellScreen] [IndexedStack]).
class CartTab extends StatelessWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Cart',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.neutral,
        ),
      ),
    );
  }
}
