/// Returns whether [raw] matches `ipot://table/{tableId}` with a single
/// non-empty table id path segment (scheme and host are compared case-insensitively).
bool isValidIpotTableQr(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return false;

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return false;
  if (uri.scheme.toLowerCase() != 'ipot') return false;
  if (uri.host.toLowerCase() != 'table') return false;
  if (uri.userInfo.isNotEmpty) return false;

  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.length != 1) return false;
  return segments.single.isNotEmpty;
}
