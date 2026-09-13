import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/auth_provider.dart';
import 'brand_logo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardShell extends ConsumerWidget {
  final String title;
  final String subtitle;
  final String selected;
  final Widget child;
  final List<DashboardNavItem> items;

  const DashboardShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.child,
    required this.items,
  });

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return Scaffold(
      drawer: _MobileDrawer(
        items: items,
        selected: selected,
        userName: user?.name ?? 'User',
        role: user?.role ?? '',
        onLogout: () => _logout(context, ref),
      ),
      body: Row(
        children: [
          if (MediaQuery.sizeOf(context).width >= 900)
            _Sidebar(
              items: items,
              selected: selected,
              userName: user?.name ?? 'User',
              role: user?.role ?? '',
              onLogout: () => _logout(context, ref),
            ),
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  title: title,
                  subtitle: subtitle,
                  onLogout: () => _logout(context, ref),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardNavItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardNavItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class _Sidebar extends StatelessWidget {
  final List<DashboardNavItem> items;
  final String selected;
  final String userName;
  final String role;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.items,
    required this.selected,
    required this.userName,
    required this.role,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF063F22),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const BrandLogo(height: 70),
              ),
            ),
            const Divider(color: Color(0x3355A86A), height: 1),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: items.map((item) {
                  final active = item.label == selected;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      onTap: item.onTap,
                      selected: active,
                      selectedTileColor: const Color(0xFF17713B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      leading: Icon(
                        item.icon,
                        color: active ? Colors.white : const Color(0xFFC7E8CF),
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          color: active ? Colors.white : const Color(0xFFDDF1E2),
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D5B30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFB7E86B),
                          child: Icon(Icons.person, color: Color(0xFF063F22)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                role.replaceAll('_', ' '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFB9DCC2),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout, color: Color(0xFFB9DCC2)),
                    label: const Text('Sign out', style: TextStyle(color: Color(0xFFB9DCC2))),
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

class _MobileDrawer extends StatelessWidget {
  final List<DashboardNavItem> items;
  final String selected;
  final String userName;
  final String role;
  final VoidCallback onLogout;

  const _MobileDrawer({
    required this.items,
    required this.selected,
    required this.userName,
    required this.role,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: BrandLogo(height: 90),
            ),
            Expanded(
              child: ListView(
                children: items.map((item) => ListTile(
                  selected: item.label == selected,
                  leading: Icon(item.icon),
                  title: Text(item.label),
                  onTap: () {
                    Navigator.pop(context);
                    item.onTap();
                  },
                )).toList(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(userName),
              subtitle: Text(role.replaceAll('_', ' ')),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onLogout;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 900;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2EAE4))),
      ),
      padding: EdgeInsets.fromLTRB(mobile ? 8 : 28, 12, 20, 12),
      child: Row(
        children: [
          if (mobile) Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF113A23),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6D7E73),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications will appear here.')),
            ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
    );
  }
}
