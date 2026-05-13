import 'package:flutter_test/flutter_test.dart';
import 'package:ipotapp/utils/realtime_orders_channel.dart';

void main() {
  test('realtimeOrdersChannelTopic prefixes table id', () {
    expect(realtimeOrdersChannelTopic('T001'), 'orders:T001');
    expect(realtimeOrdersChannelTopic('  x  '), 'orders:x');
  });

  test('broadcast event name is stable for mock-api parity', () {
    expect(kRealtimeOrdersBroadcastEvent, 'order_event');
  });
}
