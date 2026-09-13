import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../widgets/product_card.dart';
import 'add_product_screen.dart';

class MyProductsScreen extends ConsumerWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(myProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Crops'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(myProductsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          ref.invalidate(myProductsProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Crop'),
      ),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No crops yet. Add your first crop.'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(myProductsProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: items.map((product) {
                return ProductCard(
                  product: product,
                  onDelete: () async {
                    await ref.read(productRepositoryProvider).delete(product.id);
                    ref.invalidate(myProductsProvider);
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
