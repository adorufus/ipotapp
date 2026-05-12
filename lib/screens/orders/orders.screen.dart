import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/models/api_error.model.dart';
import 'package:ipotapp/models/order.model.dart';
import 'package:ipotapp/services/pending_orders_store.dart';
import 'package:ipotapp/state/providers.dart';
import 'package:ipotapp/utils/color_utils.dart';

/// Loads queued offline orders from [PendingOrdersStore].
final pendingOrdersListProvider =
    FutureProvider.autoDispose<List<PendingOrderEntry>>((ref) {
      return ref.watch(pendingOrdersStoreProvider).loadAll();
    });

/// Orders tab body (used inside [AppShellScreen] [IndexedStack]).
class OrdersTab extends ConsumerWidget {
  const OrdersTab({super.key});

  static const _ordersTabIndex = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<int>(bottomNavIndexProvider, (previous, next) {
      if (next == _ordersTabIndex) {
        ref.invalidate(pendingOrdersListProvider);
      }
    });

    ref.listen(deviceNetworkStatusProvider, (previous, next) {
      next.whenData((status) {
        if (status != DeviceNetworkStatus.offline) {
          Future<void>.delayed(const Duration(milliseconds: 600), () {
            ref.invalidate(pendingOrdersListProvider);
          });
        }
      });
    });

    ref.listen(checkoutControllerProvider, (previous, next) {
      final id = next.lastOrder?.id;
      if (id != null && id.startsWith('local_')) {
        ref.invalidate(pendingOrdersListProvider);
      }
    });

    final checkout = ref.watch(checkoutControllerProvider);
    final pendingAsync = ref.watch(pendingOrdersListProvider);
    final last = checkout.lastOrder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (checkout.submitting)
          Semantics(
            label: 'Placing order',
            child: const LinearProgressIndicator(minHeight: 3),
          ),
        if (checkout.submitError != null)
          Material(
            color: const Color(0xFFFFF4E5),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      checkout.submitError!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Dismiss',
                    onPressed: () => ref
                        .read(checkoutControllerProvider.notifier)
                        .clearSubmitError(),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _onRefresh(ref),
            child: pendingAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Could not load pending orders: $e',
                    style: const TextStyle(color: AppColors.neutral),
                  ),
                ],
              ),
              data: (pending) {
                final pendingDisplayed = pending
                    .where((e) => last == null || e.localId != last.id)
                    .toList();
                final hasQueue = pendingDisplayed.isNotEmpty;
                final hasLast = last != null;

                if (!hasQueue && !hasLast) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 48),
                      const ExcludeSemantics(
                        child: Icon(
                          Icons.receipt_long_outlined,
                          size: 56,
                          color: AppColors.mutedOnLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No orders yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'When you check out from the cart, your order will show up here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: AppColors.mutedOnLight,
                        ),
                      ),
                    ],
                  );
                }

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    if (hasQueue) ...[
                      const _SectionTitle('Waiting to send'),
                      const SizedBox(height: 10),
                      ...pendingDisplayed.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PendingOrderCard(entry: e),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (hasLast) ...[
                      const _SectionTitle('Latest order'),
                      const SizedBox(height: 10),
                      _LastOrderCard(order: last),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> _onRefresh(WidgetRef ref) async {
    ref.invalidate(pendingOrdersListProvider);
    final last = ref.read(checkoutControllerProvider).lastOrder;
    if (last != null && !last.id.startsWith('local_')) {
      try {
        await ref
            .read(checkoutControllerProvider.notifier)
            .refreshOrder(orderId: last.id);
      } on ApiError {
        // Keep last known order; error banner uses checkout.submitError
      } catch (_) {}
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        color: AppColors.mutedOnLight,
      ),
    );
  }
}

class _PendingOrderCard extends StatelessWidget {
  const _PendingOrderCard({required this.entry});

  final PendingOrderEntry entry;

  @override
  Widget build(BuildContext context) {
    final n = entry.request.items.fold<int>(0, (s, i) => s + i.quantity);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Table ${entry.request.tableId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$n items • will send when you are online',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedOnLight.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.localId,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.mutedOnLight.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LastOrderCard extends ConsumerWidget {
  const _LastOrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocal = order.id.startsWith('local_');
    final checkout = ref.watch(checkoutControllerProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.id,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral,
                    ),
                  ),
                ),
                if (isLocal)
                  _StatusChip(
                    label: 'Pending sync',
                    color: const Color(0xFFB45309),
                  )
                else
                  _StatusChip(
                    label: _statusLabel(order.status),
                    color: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Table ${order.tableId}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedOnLight.withValues(alpha: 0.85),
              ),
            ),
            if (order.total != null) ...[
              const SizedBox(height: 8),
              Text(
                'Total: \$${order.total!.toStringAsFixed(2)} ${order.currency ?? ''}'
                    .trim(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral,
                ),
              ),
            ],
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              ...order.items.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${line.quantity}×',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          line.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral,
                          ),
                        ),
                      ),
                      Text(
                        '\$${line.lineTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedOnLight.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (!isLocal) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: checkout.submitting
                        ? null
                        : () async {
                            try {
                              await ref
                                  .read(checkoutControllerProvider.notifier)
                                  .refreshOrder(orderId: order.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order updated from server'),
                                ),
                              );
                            } on ApiError catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.message)),
                              );
                            }
                          },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: checkout.submitting
                        ? null
                        : () => _confirmCancel(context, ref, order.id),
                    icon: Icon(
                      Icons.cancel_outlined,
                      size: 18,
                      color: Colors.red.shade700,
                    ),
                    label: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text(
          'This asks the restaurant system to remove the order. You can’t undo this from the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Cancel order', style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(checkoutControllerProvider.notifier).cancelOrder(
            orderId: orderId,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled')),
      );
    } on ApiError catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

String _statusLabel(OrderStatus s) {
  switch (s) {
    case OrderStatus.pending:
      return 'Pending';
    case OrderStatus.confirmed:
      return 'Confirmed';
    case OrderStatus.preparing:
      return 'Preparing';
    case OrderStatus.ready:
      return 'Ready';
    case OrderStatus.served:
      return 'Served';
  }
}
