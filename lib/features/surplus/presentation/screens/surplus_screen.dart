import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/auth_provider.dart';

final surplusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final response = await ref.watch(apiClientProvider).get('/market/summary');
  return Map<String, dynamic>.from(response.data as Map);
});

class SurplusScreen extends ConsumerWidget {
  const SurplusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(surplusProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Surplus Monitor')),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Unable to load surplus: $error')),
        data: (data) {
          final open = data['international_market_open'] == true;
          final pct = ((data['surplus_percentage'] as num).toDouble() * 100);
          final threshold = ((data['threshold'] as num).toDouble() * 100);
          final supply = (data['total_supply_kg'] as num).toDouble();
          final demand = (data['domestic_demand_kg'] as num).toDouble();
          final surplus = (data['surplus_kg'] as num).toDouble();
          final progress = (pct / threshold).clamp(0.0, 1.0);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(surplusProvider),
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 40), children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: open ? const Color(0xFFEAF6E8) : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: open ? const Color(0xFFB9DDBD) : const Color(0xFFE2EAE2))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [CircleAvatar(radius: 27, backgroundColor: open ? const Color(0xFFB7E86B) : const Color(0xFFEAF6E8), child: Icon(open ? Icons.public : Icons.home_work_outlined, color: const Color(0xFF0B4B29))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(open ? 'International Market Open' : 'Domestic Market Active', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Color(0xFF0B4B29))), Text(open ? 'Surplus threshold has been reached.' : 'No export activation for the current surplus level.', style: const TextStyle(color: Color(0xFF63756A)))]))]),
                  const SizedBox(height: 24),
                  Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xFF116B38))),
                  const Text('Current surplus', style: TextStyle(color: Color(0xFF6D7E73))),
                  const SizedBox(height: 14),
                  ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(minHeight: 12, value: progress, backgroundColor: const Color(0xFFE2EAE2))),
                  const SizedBox(height: 8),
                  Text('Activation threshold: ${threshold.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: Color(0xFF6D7E73))),
                ]),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(builder: (context, constraints) {
                final count = constraints.maxWidth >= 800 ? 3 : 1;
                final width = (constraints.maxWidth - (count - 1) * 14) / count;
                return Wrap(spacing: 14, runSpacing: 14, children: [
                  _Metric(width: width, icon: Icons.inventory_2_outlined, label: 'Total Supply', value: '${supply.toStringAsFixed(0)} kg'),
                  _Metric(width: width, icon: Icons.shopping_basket_outlined, label: 'Domestic Demand', value: '${demand.toStringAsFixed(0)} kg'),
                  _Metric(width: width, icon: Icons.trending_up_rounded, label: 'Surplus', value: '${surplus.toStringAsFixed(0)} kg'),
                ]);
              }),
              const SizedBox(height: 20),
              if (data['crops'] is List && (data['crops'] as List).isNotEmpty) ...[
                const Text('Crop-level status', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF113A23))),
                const SizedBox(height: 10),
                ...(data['crops'] as List).map((item) {
                  final crop = Map<String, dynamic>.from(item as Map);
                  final cropOpen = crop['international_market_open'] == true;
                  return Card(child: ListTile(leading: CircleAvatar(backgroundColor: const Color(0xFFEAF6E8), child: Text(crop['crop_name'].toString().substring(0, 1).toUpperCase())), title: Text(crop['crop_name'].toString(), style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${crop['total_supply_kg']} kg supply • ${crop['surplus_percentage'] is num ? ((crop['surplus_percentage'] as num) * 100).toStringAsFixed(1) : '0'}% surplus'), trailing: Chip(label: Text(cropOpen ? 'EXPORT' : 'DOMESTIC'))));
                }),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(onPressed: () => ref.invalidate(surplusProvider), icon: const Icon(Icons.refresh), label: const Text('Refresh market data')),
            ]),
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final double width; final IconData icon; final String label; final String value;
  const _Metric({required this.width, required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => SizedBox(width: width, child: Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [Container(width: 45, height: 45, decoration: BoxDecoration(color: const Color(0xFFEAF6E8), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF116B38))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Color(0xFF6D7E73))), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF113A23)))]))]))));
}
