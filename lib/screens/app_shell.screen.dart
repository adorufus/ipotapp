import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/components/app_scaffold.dart';
import 'package:ipotapp/components/language_menu_button.dart';
import 'package:ipotapp/components/network_status_banner.dart';
import 'package:ipotapp/l10n/app_localizations.dart';
import 'package:ipotapp/screens/cart/cart.screen.dart';
import 'package:ipotapp/screens/menu/menu.screen.dart';
import 'package:ipotapp/screens/orders/orders.screen.dart';
import 'package:ipotapp/state/providers.dart';
import 'package:ipotapp/utils/color_utils.dart';

import 'menu/providers/qr_scan.provider.dart';

/// Root shell: one [Scaffold], [IndexedStack] for tabs — no route transition on tab change.
class AppShellScreen extends ConsumerWidget {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(deviceNetworkStatusProvider, (previous, next) {
      next.whenData((status) {
        if (status != DeviceNetworkStatus.offline) {
          Future.microtask(
            () => ref.read(orderOutboundSyncProvider).flushIfOnline(),
          );
        }
      });
    });

    final idx = ref.watch(bottomNavIndexProvider);
    final qrState = ref.watch(qrScanControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final title = qrState.qrCode != null
        ? l10n.tableTitle(qrState.qrCode!.split('/').last)
        : l10n.welcomeToIpot;

    return Scaffold(
      extendBodyBehindAppBar: idx == 0,
      backgroundColor: AppColors.secondary,
      appBar: GlobalGlassAppBar(
        title: title,
        actions: [
          const LanguageMenuButton(),
          IconButton(
            tooltip: l10n.infoTooltip,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.infoComingSoon)),
              );
            },
            icon: const Icon(Icons.info_outline, color: AppColors.neutral),
          ),
        ],
      ),
      body: SafeArea(
        top: idx != 0,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NetworkStatusBanner(),
            Expanded(
              child: IndexedStack(
                index: idx,
                sizing: StackFit.expand,
                children: const [MenuOrQrTab(), CartTab(), OrdersTab()],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
