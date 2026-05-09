import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/components/app_scaffold.dart';
import 'package:ipotapp/screens/cart.screen.dart';
import 'package:ipotapp/screens/orders.screen.dart';
import 'package:ipotapp/screens/qr_scan.screen.dart';
import 'package:ipotapp/state/providers.dart';
import 'package:ipotapp/utils/color_utils.dart';

import 'providers/qr_scan.provider.dart';

/// Root shell: one [Scaffold], [IndexedStack] for tabs — no route transition on tab change.
class AppShellScreen extends ConsumerWidget {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(bottomNavIndexProvider);
    final qrState = ref.watch(qrScanControllerProvider);
    final title = qrState.qrCode != null
        ? 'Table ${qrState.qrCode?.split('/').last}'
        : 'Welcome to Ipot';

    return Scaffold(
      extendBodyBehindAppBar: idx == 0,
      backgroundColor: idx == 0 ? Colors.transparent : AppColors.secondary,
      appBar: GlobalGlassAppBar(
        title: title,
        actions: [
          IconButton(
            tooltip: 'Info',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Info coming soon')),
              );
            },
            icon: const Icon(Icons.info_outline, color: AppColors.neutral),
          ),
        ],
      ),
      body: SafeArea(
        top: idx != 0,
        bottom: false,
        child: IndexedStack(
          index: idx,
          sizing: StackFit.expand,
          children: const [
            QrScanTab(),
            CartTab(),
            OrdersTab(),
          ],
        ),
      ),
      floatingActionButton: idx == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.secondary,
              onPressed: () {
                ref.read(qrScanControllerProvider.notifier).pause();
              },
              child: const Icon(Icons.list_alt),
            )
          : null,
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
