import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/state/core/connectivity_providers.dart';
import 'package:ipotapp/state/core/device_network_status.dart';

/// Shows a compact bar when the device has no local network link.
///
/// When online, the app can still read [deviceNetworkStatusProvider] elsewhere
/// (e.g. to tune UI or retry requests).
class NetworkStatusBanner extends ConsumerWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(deviceNetworkStatusProvider);

    return async.when(
      data: (status) {
        if (status != DeviceNetworkStatus.offline) {
          return const SizedBox.shrink();
        }
        return Semantics(
          container: true,
          liveRegion: true,
          label: "You're offline. Check Wi-Fi or mobile data.",
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
                      "You're offline. Check Wi‑Fi or mobile data.",
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
      },
      loading: () => const SizedBox.shrink(),
      error: (Object? error, StackTrace stackTrace) =>
          const SizedBox.shrink(),
    );
  }
}
