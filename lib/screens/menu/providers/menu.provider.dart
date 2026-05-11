import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/models/menu_response.model.dart';
import 'package:ipotapp/repositories/menu_repository.dart';
import 'package:ipotapp/state/providers.dart';

import 'qr_scan.provider.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository(ref.watch(httpServiceProvider));
});

final menuResponseProvider = FutureProvider.autoDispose<MenuResponse>((
  ref,
) async {
  final qrState = ref.watch(qrScanControllerProvider);
  final raw = qrState.qrCode;
  final tableId = _tryParseTableId(raw);

  return ref.watch(menuRepositoryProvider).fetchMenu(tableId: tableId);
});

String? _tryParseTableId(String? raw) {
  if (raw == null || raw.isEmpty) return null;

  try {
    final uri = Uri.tryParse(raw);
    if (uri == null) return raw;
    final segs = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    return segs.isEmpty ? raw : segs.last;
  } catch (_) {
    return raw;
  }
}
