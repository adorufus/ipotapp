import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/models/menu_response.model.dart';
import 'package:ipotapp/models/order.model.dart';
import 'package:ipotapp/screens/menu/providers/menu.provider.dart';
import 'package:ipotapp/utils/realtime_orders_channel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Server-driven order updates (status, timeline) merged into the orders UI.
final realtimeOrdersPatchProvider =
    StateNotifierProvider.autoDispose<RealtimeOrdersNotifier, RealtimeOrdersPatch>(
      (ref) {
        final notifier = RealtimeOrdersNotifier(ref);
        ref.onDispose(notifier.teardownRealtime);
        ref.listen<AsyncValue<MenuResponse>>(
          menuResponseProvider,
          (_, next) {
            Future.microtask(() {
              next.when(
                data: notifier.onMenuData,
                error: (err, stack) => notifier.clear(),
                loading: () {},
              );
            });
          },
          fireImmediately: true,
        );
        return notifier;
      },
    );

@immutable
class RealtimeOrdersPatch {
  final Map<String, Order> overrides;
  final Set<String> removedIds;

  const RealtimeOrdersPatch({
    required this.overrides,
    required this.removedIds,
  });

  factory RealtimeOrdersPatch.initial() => RealtimeOrdersPatch(
    overrides: <String, Order>{},
    removedIds: <String>{},
  );

  RealtimeOrdersPatch copyWith({
    Map<String, Order>? overrides,
    Set<String>? removedIds,
  }) {
    return RealtimeOrdersPatch(
      overrides: overrides ?? this.overrides,
      removedIds: removedIds ?? this.removedIds,
    );
  }
}

class RealtimeOrdersNotifier extends StateNotifier<RealtimeOrdersPatch> {
  RealtimeOrdersNotifier(this.ref) : super(RealtimeOrdersPatch.initial());

  final Ref ref;
  RealtimeChannel? _channel;
  String? _connectedTableId;

  void clear() {
    teardownRealtime();
    state = RealtimeOrdersPatch.initial();
  }

  void onMenuData(MenuResponse menu) {
    final tid = menu.restaurant.tableId.trim();
    if (tid.isEmpty) {
      clear();
      return;
    }
    _subscribeTable(tid);
  }

  void teardownRealtime() {
    final ch = _channel;
    _channel = null;
    _connectedTableId = null;
    if (ch != null) {
      unawaited(ch.unsubscribe());
    }
  }

  void _subscribeTable(String tableId) {
    if (_connectedTableId == tableId && _channel != null) return;
    teardownRealtime();
    state = RealtimeOrdersPatch.initial();
    _connectedTableId = tableId;

    if (!Supabase.instance.isInitialized) {
      _connectedTableId = null;
      return;
    }

    final topic = realtimeOrdersChannelTopic(tableId);
    final ch = Supabase.instance.client.channel(
      topic,
      opts: const RealtimeChannelConfig(ack: false),
    );

    ch
        .onBroadcast(
          event: kRealtimeOrdersBroadcastEvent,
          callback: _onBroadcastPayload,
        )
        .subscribe((status, err) {
          if (!kDebugMode) return;
          if (status == RealtimeSubscribeStatus.subscribed) {
            debugPrint('realtime orders subscribed topic=$topic');
          } else if (status == RealtimeSubscribeStatus.channelError) {
            debugPrint('realtime orders channel error topic=$topic err=$err');
          } else if (status == RealtimeSubscribeStatus.timedOut) {
            debugPrint('realtime orders subscribe timed out topic=$topic');
          } else if (status == RealtimeSubscribeStatus.closed) {
            debugPrint('realtime orders channel closed topic=$topic');
          }
        });

    _channel = ch;
  }

  void _onBroadcastPayload(Map<String, dynamic> envelope) {
    final json = _unwrapBroadcastEnvelope(envelope);
    if (json == null) {
      if (kDebugMode) {
        debugPrint(
          'realtime orders: ignored broadcast (could not parse body). '
          'Keys: ${envelope.keys.toList()}',
        );
      }
      return;
    }

    final type = json['type']?.toString();
    if (type == 'order_updated' && json['order'] is Map) {
      try {
        final order = Order.fromJson(
          (json['order']! as Map).cast<String, dynamic>(),
        );
        _applyPatchWhenMounted(() {
          final nextRemoved = Set<String>.from(state.removedIds)..remove(order.id);
          final nextOverrides = Map<String, Order>.from(state.overrides)
            ..[order.id] = order;
          state = RealtimeOrdersPatch(
            overrides: nextOverrides,
            removedIds: nextRemoved,
          );
        });
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('realtime orders: Order.fromJson failed: $e\n$st');
        }
        return;
      }
    } else if (type == 'order_deleted') {
      final id = json['order_id']?.toString();
      if (id == null || id.isEmpty) return;
      _applyPatchWhenMounted(() {
        final nextRemoved = Set<String>.from(state.removedIds)..add(id);
        final nextOverrides = Map<String, Order>.from(state.overrides)..remove(id);
        state = RealtimeOrdersPatch(
          overrides: nextOverrides,
          removedIds: nextRemoved,
        );
      });
    }
  }

  void _applyPatchWhenMounted(void Function() apply) {
    Future.microtask(() {
      try {
        apply();
      } catch (_) {
        /* malformed payload or disposed notifier */
      }
    });
  }
}

List<Order> mergeOrdersWithRealtimePatch(
  List<Order> base,
  RealtimeOrdersPatch patch,
) {
  if (patch.overrides.isEmpty && patch.removedIds.isEmpty) return base;
  final out = <Order>[];
  for (final o in base) {
    if (patch.removedIds.contains(o.id)) continue;
    final p = patch.overrides[o.id];
    if (p == null) {
      out.add(o);
    } else {
      out.add(_newerOrderByUpdatedAt(o, p));
    }
  }
  out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return out;
}

Order _newerOrderByUpdatedAt(Order a, Order b) {
  if (b.updatedAt.compareTo(a.updatedAt) >= 0) return b;
  return a;
}

Order? mergeOrderWithRealtimePatch(Order? order, RealtimeOrdersPatch patch) {
  if (order == null) return null;
  if (patch.removedIds.contains(order.id)) return null;
  final p = patch.overrides[order.id];
  if (p == null) return order;
  return _newerOrderByUpdatedAt(order, p);
}

/// Normalizes Supabase / Phoenix broadcast shapes to `{ type, order? | order_id? }`.
Map<String, dynamic>? _unwrapBroadcastEnvelope(Map<String, dynamic> envelope) {
  dynamic cursor = envelope;

  for (var i = 0; i < 4; i++) {
    if (cursor is String) {
      try {
        final decoded = jsonDecode(cursor);
        cursor = decoded;
      } catch (_) {
        return null;
      }
    }
    if (cursor is! Map) return null;
    final m = Map<String, dynamic>.from(cursor);

    if (m['type']?.toString() == 'order_updated' ||
        m['type']?.toString() == 'order_deleted') {
      return m;
    }

    final next = m['payload'] ?? m['record'] ?? m['data'];
    if (next == null) return null;
    cursor = next;
  }

  return null;
}
