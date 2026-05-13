/// Supabase Realtime **broadcast** channel naming for table-scoped order patches.
///
/// Must stay in sync with [mock-api/lib/supabaseOrderBroadcast.js] `topicForTable`.
String realtimeOrdersChannelTopic(String tableId) {
  final t = tableId.trim();
  return 'orders:$t';
}

/// Broadcast event name (server [httpSend] / client [onBroadcast]).
const kRealtimeOrdersBroadcastEvent = 'order_event';
