import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/l10n/app_localizations.dart';
import 'package:ipotapp/state/core/connectivity_providers.dart';
import 'package:ipotapp/state/core/device_network_status.dart';

/// Shows a compact bar when the device has no local network link.
///
/// When online, the app can still read [deviceNetworkStatusProvider] elsewhere
/// (e.g. to tune UI or retry requests).
///
/// Set [belowToolbar] when the scaffold body extends behind a transparent app
/// bar (e.g. menu tab): the banner is inset below the status bar and toolbar so
/// it is not covered by system UI or the app bar.
class NetworkStatusBanner extends ConsumerWidget {
  const NetworkStatusBanner({super.key, this.belowToolbar = false});

  final bool belowToolbar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(deviceNetworkStatusProvider);

    return async.when(
      data: (status) {
        if (status != DeviceNetworkStatus.offline) {
          return const SizedBox.shrink();
        }
        final l10n = AppLocalizations.of(context)!;
        final message = l10n.offlineBannerMessage;
        final bar = Semantics(
          container: true,
          liveRegion: true,
          label: message,
          child: Material(
            color: const Color(0xFFB42318),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        return SafeArea(
          bottom: false,
          left: false,
          right: false,
          top: true,
          minimum: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.only(
              top: belowToolbar ? kToolbarHeight : 0,
            ),
            child: bar,
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (Object? error, StackTrace stackTrace) =>
          const SizedBox.shrink(),
    );
  }
}
