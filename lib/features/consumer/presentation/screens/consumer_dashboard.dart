import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/dashboard_shell.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../products/presentation/providers.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../surplus/presentation/screens/surplus_screen.dart';

class ConsumerDashboard extends ConsumerWidget {
  const ConsumerDashboard({super.key});

  Future<void> _buy(BuildContext context, WidgetRef ref, product) async {
    final controller = TextEditingController(text: '1');
    final quantity = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Buy ${product.cropName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('₹${product.pricePerKg.toStringAsFixed(2)} per kg'),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Quantity (kg)',
                prefixIcon: Icon(Icons.scale_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, double.tryParse(controller.text)),
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
        data: {'product_id': product.id, 'quantity_kg': quantity},
      );
      ref.invalidate(marketplaceProductsProvider);
      ref.invalidate(ordersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final products = ref.watch(marketplaceProductsProvider);

    return DashboardShell(
      title: 'Marketplace',
      subtitle: 'Fresh produce • Fair prices • Trusted farmers',
      selected: 'Marketplace',
      items: [
        DashboardNavItem(label: 'Marketplace', icon: Icons.storefront_outlined, onTap: () {}),
        DashboardNavItem(label: 'My Orders', icon: Icons.receipt_long_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
        DashboardNavItem(label: 'Market Status', icon: Icons.insights_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SurplusScreen()))),
      ],
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(marketplaceProductsProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
          children: [
            _Hero(userName: user?.name ?? 'Consumer'),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.eco_outlined, color: Color(0xFF23864A), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Available Products', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF113A23))),
                ),
                TextButton(onPressed: () => ref.invalidate(marketplaceProductsProvider), child: const Text('Refresh')),
              ],
            ),
            const Text('Fresh quality produce from farmers on AgriNova.', style: TextStyle(color: Color(0xFF718075))),
            const SizedBox(height: 12),
            products.when(
              loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
              error: (error, _) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Text('Unable to load products: $error'))),
              data: (items) {
                if (items.isEmpty) {
                  return const Card(child: Padding(padding: EdgeInsets.all(30), child: Center(child: Text('No crops available right now.'))));
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1200 ? 4 : constraints.maxWidth >= 760 ? 2 : 1;
                    if (columns == 1) {
                      return Column(children: items.map((p) => ProductCard(product: p, onBuy: () => _buy(context, ref, p))).toList());
                    }
                    final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
                    return Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: items.map((p) => SizedBox(width: width, child: ProductCard(product: p, onBuy: () => _buy(context, ref, p)))).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String userName;
  const _Hero({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 230),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFEAF6E8), Color(0xFFD5EFD5)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD1E7D3)),
      ),
      child: Stack(
        children: [
          Positioned(right: -8, bottom: -20, child: Opacity(opacity: .13, child: Icon(Icons.eco, size: 190, color: const Color(0xFF116B38)))),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Container(width: 54, height: 54, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const BrandLogo(height: 44)), const SizedBox(width: 12), const Text('AgriNova', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF063F22)))]),
            const SizedBox(height: 18),
            Text('Welcome, $userName 👋', style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: Color(0xFF0B4B29))),
            const SizedBox(height: 6),
            const Text('Connecting farmers and consumers for a fairer food market.', style: TextStyle(fontSize: 15, color: Color(0xFF42634D))),
            const SizedBox(height: 20),
            Wrap(spacing: 10, runSpacing: 10, children: [
              FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.storefront_outlined), label: const Text('Explore Marketplace')),
              OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SurplusScreen())), icon: const Icon(Icons.analytics_outlined), label: const Text('View Surplus')),
            ]),
          ]),
        ],
      ),
    );
  }
}
