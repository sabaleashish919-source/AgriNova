import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/dashboard_shell.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../products/presentation/providers.dart';
import '../../../products/presentation/screens/add_product_screen.dart';
import '../../../products/presentation/screens/my_products_screen.dart';
import '../../../surplus/presentation/screens/surplus_screen.dart';

class FarmerDashboard extends ConsumerWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final products = ref.watch(myProductsProvider);

    return DashboardShell(
      title: 'Farmer Dashboard',
      subtitle: 'Manage your crops, orders and market opportunities',
      selected: 'Home',
      items: [
        DashboardNavItem(
          label: 'Home',
          icon: Icons.home_outlined,
          onTap: () {},
        ),
        DashboardNavItem(
          label: 'My Crops',
          icon: Icons.agriculture_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MyProductsScreen(),
              ),
            );
          },
        ),
        DashboardNavItem(
          label: 'Orders',
          icon: Icons.receipt_long_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrdersScreen(),
              ),
            );
          },
        ),
        DashboardNavItem(
          label: 'Surplus Monitor',
          icon: Icons.insights_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SurplusScreen(),
              ),
            );
          },
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          22,
          20,
          40,
        ),
        children: [
          _FarmerHero(
            name: user?.name ?? 'Farmer',
            onAdd: () => _addCrop(
              context,
              ref,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Marketplace Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF113A23),
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Keep track of your harvest, available stock and export '
            'opportunities from one place.',
            style: TextStyle(
              color: Color(0xFF718075),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          products.when(
            loading: () {
              return const SizedBox(
                height: 180,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            error: (error, stackTrace) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFB3261E),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Unable to load your crops: $error',
                          style: const TextStyle(
                            color: Color(0xFFB3261E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            data: (items) {
              final double totalStock = items.fold<double>(
                0,
                (sum, product) => sum + product.quantityKg,
              );

              final bool exportActive =
                  items.any((product) => product.exportOnly);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final int columnCount;

                  if (constraints.maxWidth >= 1050) {
                    columnCount = 3;
                  } else if (constraints.maxWidth >= 650) {
                    columnCount = 2;
                  } else {
                    columnCount = 1;
                  }

                  final double cardWidth = columnCount == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - ((columnCount - 1) * 14)) /
                          columnCount;

                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _StatCard(
                        width: cardWidth,
                        icon: Icons.inventory_2_outlined,
                        title: 'Listed Crops',
                        value: '${items.length}',
                        detail: 'Products in your marketplace',
                      ),
                      _StatCard(
                        width: cardWidth,
                        icon: Icons.scale_outlined,
                        title: 'Available Stock',
                        value: '${totalStock.toStringAsFixed(0)} kg',
                        detail: 'Across your active listings',
                      ),
                      _StatCard(
                        width: cardWidth,
                        icon: Icons.public_outlined,
                        title: 'Export Status',
                        value: exportActive ? 'OPEN' : 'CLOSED',
                        detail: exportActive
                            ? 'Surplus opportunity active'
                            : 'Domestic market active',
                        highlighted: exportActive,
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: Color(0xFF23864A),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF113A23),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final int columnCount = constraints.maxWidth >= 850 ? 3 : 1;

              final double cardWidth = columnCount == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - ((columnCount - 1) * 14)) /
                      columnCount;

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _ActionCard(
                    width: cardWidth,
                    icon: Icons.add_circle_outline,
                    title: 'Add Crop',
                    subtitle: 'List fresh produce',
                    onTap: () => _addCrop(
                      context,
                      ref,
                    ),
                  ),
                  _ActionCard(
                    width: cardWidth,
                    icon: Icons.receipt_long_outlined,
                    title: 'View Orders',
                    subtitle: 'Track consumer orders',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrdersScreen(),
                        ),
                      );
                    },
                  ),
                  _ActionCard(
                    width: cardWidth,
                    icon: Icons.analytics_outlined,
                    title: 'Surplus Monitor',
                    subtitle: 'See market activation',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SurplusScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          _FarmerGuidanceCard(),
        ],
      ),
    );
  }

  Future<void> _addCrop(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddProductScreen(),
      ),
    );

    ref.invalidate(myProductsProvider);
  }
}

class _FarmerHero extends StatelessWidget {
  final String name;
  final VoidCallback onAdd;

  const _FarmerHero({
    required this.name,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0A542B),
            Color(0xFF23864A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 650;

          final logo = Container(
            width: 70,
            height: 70,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const BrandLogo(
              height: 55,
            ),
          );

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good to see you, $name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Turn your harvest into better market opportunities.',
                style: TextStyle(
                  color: Color(0xFFD8F0DD),
                  fontSize: 14,
                ),
              ),
            ],
          );

          final addButton = FilledButton.icon(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB7E86B),
              foregroundColor: const Color(0xFF063F22),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              'Add Crop',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                logo,
                const SizedBox(height: 18),
                content,
                const SizedBox(height: 20),
                addButton,
              ],
            );
          }

          return Row(
            children: [
              logo,
              const SizedBox(width: 18),
              Expanded(
                child: content,
              ),
              const SizedBox(width: 18),
              addButton,
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final bool highlighted;

  const _StatCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: highlighted
                      ? const Color(0xFFFFF3CD)
                      : const Color(0xFFEAF6E8),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: highlighted
                      ? const Color(0xFF8A6200)
                      : const Color(0xFF116B38),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF66766B),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF113A23),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7B887F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6E8),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    size: 27,
                    color: const Color(0xFF23864A),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF113A23),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718075),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF718075),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FarmerGuidanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6E8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF116B38),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How AgriNova helps you',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF113A23),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'List your crops for the domestic marketplace first. '
                    'When crop supply exceeds domestic demand by the '
                    'configured surplus threshold, eligible surplus can '
                    'be opened to international buyers.',
                    style: TextStyle(
                      color: Color(0xFF66766B),
                      height: 1.5,
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
