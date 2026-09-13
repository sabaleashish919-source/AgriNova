import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/providers/auth_provider.dart';

final ordersProvider = FutureProvider<List<dynamic>>((ref) async {
  final response = await ref.watch(apiClientProvider).get('/orders');
  return List<dynamic>.from(response.data as List);
});

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders'), actions: [IconButton(onPressed: () => ref.invalidate(ordersProvider), icon: const Icon(Icons.refresh))]),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Unable to load orders: $error'))),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No orders yet.'));
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(ordersProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final order = Map<String, dynamic>.from(items[index] as Map);
                final status = order['status']?.toString() ?? 'PENDING';
                final amount = (order['total_amount'] as num?)?.toDouble() ?? 0;
                final qty = (order['quantity_kg'] as num?)?.toDouble() ?? 0;
                final created = DateTime.tryParse(order['created_at']?.toString() ?? '');
                return Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [CircleAvatar(backgroundColor: const Color(0xFFEAF6E8), child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF116B38))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Order #${order['id']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 4), Text('${qty.toStringAsFixed(2)} kg', style: const TextStyle(color: Color(0xFF5E7064))), if (created != null) Text(DateFormat('dd MMM yyyy, hh:mm a').format(created.toLocal()), style: const TextStyle(fontSize: 11, color: Color(0xFF879189)))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('₹${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF116B38))), const SizedBox(height: 5), Chip(label: Text(status))])])));
              },
            ),
          );
        },
      ),
    );
  }
}
