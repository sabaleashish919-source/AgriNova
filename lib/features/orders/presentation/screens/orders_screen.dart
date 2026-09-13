import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      appBar: AppBar(title: const Text('My Orders')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final order = Map<String, dynamic>.from(items[index] as Map);
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text('Order #${order['id']}'),
                  subtitle: Text(
                    '${order['quantity_kg']} kg • ${order['status']}',
                  ),
                  trailing: Text('₹${order['total_amount']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
