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
          final isOpen = data['international_market_open'] == true;
          final surplusPercentage = (data['surplus_percentage'] as num).toDouble() * 100;
          final threshold = (data['threshold'] as num).toDouble() * 100;
          final supply = (data['total_supply_kg'] as num).toDouble();
          final demand = (data['domestic_demand_kg'] as num).toDouble();
          final surplus = (data['surplus_kg'] as num).toDouble();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        isOpen ? Icons.public : Icons.home_work_outlined,
                        size: 56,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isOpen
                            ? 'INTERNATIONAL MARKET OPEN'
                            : 'INTERNATIONAL MARKET CLOSED',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${surplusPercentage.toStringAsFixed(1)}% surplus • '
                        'threshold ${threshold.toStringAsFixed(0)}%',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _metric('Total supply', '${supply.toStringAsFixed(0)} kg'),
              _metric('Domestic demand', '${demand.toStringAsFixed(0)} kg'),
              _metric('Surplus', '${surplus.toStringAsFixed(0)} kg'),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => ref.invalidate(surplusProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh market'),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _metric(String label, String value) {
  return Card(
    child: ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
      ),
    ),
  );
}
