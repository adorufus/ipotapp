import 'package:connectivity_plus/connectivity_plus.dart';

/// High-level network link state derived from [ConnectivityResult] values.
///
/// This reflects **local** link status (Wi‑Fi, cellular, etc.), not whether the
/// internet or your API is reachable.
enum DeviceNetworkStatus {
  offline,
  wifi,
  cellular,
  ethernet,
  vpn,
  other,
}

DeviceNetworkStatus deviceNetworkStatusFromResults(
  List<ConnectivityResult> results,
) {
  final active = results.where((r) => r != ConnectivityResult.none).toList();
  if (active.isEmpty) return DeviceNetworkStatus.offline;

  if (active.contains(ConnectivityResult.wifi)) {
    return DeviceNetworkStatus.wifi;
  }
  if (active.contains(ConnectivityResult.ethernet)) {
    return DeviceNetworkStatus.ethernet;
  }
  if (active.contains(ConnectivityResult.mobile)) {
    return DeviceNetworkStatus.cellular;
  }
  if (active.contains(ConnectivityResult.vpn)) {
    return DeviceNetworkStatus.vpn;
  }
  return DeviceNetworkStatus.other;
}

extension DeviceNetworkStatusLabel on DeviceNetworkStatus {
  String get shortLabel => switch (this) {
    DeviceNetworkStatus.offline => 'No connection',
    DeviceNetworkStatus.wifi => 'Wi‑Fi',
    DeviceNetworkStatus.cellular => 'Mobile data',
    DeviceNetworkStatus.ethernet => 'Ethernet',
    DeviceNetworkStatus.vpn => 'VPN',
    DeviceNetworkStatus.other => 'Network',
  };
}
