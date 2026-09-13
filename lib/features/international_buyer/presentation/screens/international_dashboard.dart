import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/dashboard_shell.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../products/presentation/providers.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../surplus/presentation/screens/surplus_screen.dart';

class InternationalDashboard extends ConsumerWidget {
  const InternationalDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final products = ref.watch(exportProductsProvider);

    return DashboardShell(
      title: 'International Marketplace',
      subtitle: 'Export opportunities activated by verified crop surplus',
      selected: 'Export Marketplace',
      items: [
        DashboardNavItem(label: 'Export Marketplace', icon: Icons.public_outlined, onTap: () {}),
        DashboardNavItem(label: 'Market Status', icon: Icons.insights_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SurplusScreen()))),
      ],
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(exportProductsProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF063F22), Color(0xFF0E7351)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(width: 70, height: 70, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const BrandLogo(height: 55)),
                  const SizedBox(width: 18),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Global sourcing, made simpler', style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text('Welcome ${user?.name ?? 'Buyer'}. Explore crops released for export.', style: const TextStyle(color: Color(0xFFD8F0DD)))])),
                  const Icon(Icons.public, size: 64, color: Color(0xFFB7E86B)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(children: [const Icon(Icons.eco_outlined, color: Color(0xFF23864A)), const SizedBox(width: 9), Expanded(child: Text('Export Opportunities', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF113A23))))]),
            const SizedBox(height: 6),
            const Text('Products appear here only after the surplus threshold is reached.', style: TextStyle(color: Color(0xFF718075))),
            const SizedBox(height: 14),
            products.when(
              loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
              error: (error, _) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Text('Unable to load export products: $error'))),
              data: (items) => items.isEmpty
                  ? const Card(child: Padding(padding: EdgeInsets.all(30), child: Center(child: Text('No export products are available right now.'))))
                  : Column(children: items.map((p) => ProductCard(product: p)).toList()),
            ),
          ],
        ),
      ),
    );
  }
}
