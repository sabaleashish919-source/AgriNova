import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/auth_provider.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../products/presentation/providers.dart';
import '../../../products/presentation/widgets/product_card.dart';

class ConsumerDashboard extends ConsumerWidget {
  const ConsumerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final products = ref.watch(marketplaceProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgroSurplus Marketplace'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(marketplaceProductsProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Welcome ${user?.name ?? 'Consumer'} 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            const Text('Buy directly from farmers.'),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text('My Orders'),
            ),
            const SizedBox(height: 20),
            Text(
              'Available Crops',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            products.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No crops available right now.')),
                  );
                }

                return Column(
                  children: items.map((product) {
                    return ProductCard(
                      product: product,
                      onBuy: () async {
                        final controller = TextEditingController(text: '1');
                        final quantity = await showDialog<double>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: Text('Buy ${product.cropName}'),
                            content: TextField(
                              controller: controller,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Quantity (kg)',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(
                                    dialogContext,
                                    double.tryParse(controller.text),
                                  );
                                },
                                child: const Text('Place Order'),
                              ),
                            ],
                          ),
                        );
                        controller.dispose();

                        if (quantity == null || quantity <= 0) return;

                        try {
                          await ref.read(apiClientProvider).post(
                            '/orders',
                            data: {
                              'product_id': product.id,
                              'quantity_kg': quantity,
                            },
                          );
                          ref.invalidate(marketplaceProductsProvider);
                          ref.invalidate(ordersProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order placed successfully'),
                              ),
                            );
                          }
                        } catch (error) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())),
                            );
                          }
                        }
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error loading crops: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
