import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/dashboard_shell.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../surplus/presentation/screens/surplus_screen.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return DashboardShell(
      title: 'Admin Console',
      subtitle: 'Monitor AgriNova market activity and surplus activation',
      selected: 'Overview',
      items: [
        DashboardNavItem(
          label: 'Overview',
          icon: Icons.dashboard_outlined,
          onTap: () {},
        ),
        DashboardNavItem(
          label: 'Market Status',
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
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
        children: [
          _AdminHero(
            administratorName: user?.name ?? 'Administrator',
          ),
          const SizedBox(height: 26),
          Text(
            'Platform Management',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF113A23),
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Manage marketplace activity, monitor surplus conditions and '
            'keep AgriNova transparent for every participant.',
            style: TextStyle(
              color: Color(0xFF718075),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final int columnCount;

              if (constraints.maxWidth >= 1100) {
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
                  _AdminCard(
                    width: cardWidth,
                    icon: Icons.analytics_outlined,
                    title: 'Market & Surplus',
                    subtitle:
                        'Monitor crop supply, demand and export activation.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SurplusScreen(),
                        ),
                      );
                    },
                  ),
                  _AdminCard(
                    width: cardWidth,
                    icon: Icons.people_outline,
                    title: 'User Administration',
                    subtitle:
                        'Manage platform roles and verification workflows.',
                    onTap: () {
                      _showComingSoon(
                        context,
                        'User administration will be available in the next module.',
                      );
                    },
                  ),
                  _AdminCard(
                    width: cardWidth,
                    icon: Icons.settings_outlined,
                    title: 'Platform Settings',
                    subtitle: 'Configure marketplace policies and thresholds.',
                    onTap: () {
                      _showComingSoon(
                        context,
                        'Platform settings will be available in the next module.',
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          _AdminInfoSection(),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _AdminHero extends StatelessWidget {
  final String administratorName;

  const _AdminHero({
    required this.administratorName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6E8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD2E8D4),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 600;

          final logo = Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const BrandLogo(
              height: 56,
            ),
          );

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AgriNova Control Center',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0B4B29),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Welcome $administratorName. Keep the marketplace '
                'healthy, transparent and farmer-friendly.',
                style: const TextStyle(
                  color: Color(0xFF526A59),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                logo,
                const SizedBox(height: 18),
                content,
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
            ],
          );
        },
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminCard({
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6E8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF116B38),
                    size: 27,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF113A23),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF718075),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF23864A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.eco_outlined,
                    color: Color(0xFF116B38),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AgriNova Marketplace Logic',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF113A23),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'AgriNova keeps the domestic marketplace as the primary '
              'market. When available supply exceeds the configured '
              'domestic-demand threshold, eligible crop listings can '
              'become available to international buyers.',
              style: TextStyle(
                color: Color(0xFF66766B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
