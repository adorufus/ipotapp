import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'device_network_status.dart';

/// Raw connectivity events from the platform (singleton [Connectivity]).
final connectivityPluginProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Current and updating [DeviceNetworkStatus] (offline, Wi‑Fi, cellular, …).
///
/// Emits once from [Connectivity.checkConnectivity], then follows
/// [Connectivity.onConnectivityChanged].
final deviceNetworkStatusProvider =
    StreamProvider<DeviceNetworkStatus>((ref) async* {
      final connectivity = ref.watch(connectivityPluginProvider);
      yield deviceNetworkStatusFromResults(
        await connectivity.checkConnectivity(),
      );
      await for (final results in connectivity.onConnectivityChanged) {
        yield deviceNetworkStatusFromResults(results);
      }
    });
