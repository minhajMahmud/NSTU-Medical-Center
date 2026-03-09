import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/utils/role_utils.dart';

class _NavItem {
  const _NavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthController>().appRole;
    final items = _itemsForRole(role);
    final path = GoRouterState.of(context).uri.path;
    final selected = _indexFromLocation(path, items);

    return NavigationRail(
      selectedIndex: selected,
      onDestinationSelected: (index) {
        context.go(items[index].route);
      },
      labelType: NavigationRailLabelType.all,
      destinations: [
        for (final item in items)
          NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: Text(item.label),
          ),
      ],
    );
  }

  int _indexFromLocation(String path, List<_NavItem> items) {
    for (var i = 0; i < items.length; i++) {
      if (path.startsWith(items[i].route)) return i;
    }
    return 0;
  }

  List<_NavItem> _itemsForRole(AppRole role) {
    switch (role) {
      case AppRole.patient:
        return const [
          _NavItem(
            route: '/patient/dashboard',
            label: 'Dashboard',
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
          ),
          _NavItem(
            route: '/patient/profile',
            label: 'Profile',
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
          ),
          _NavItem(
            route: '/patient/doctors',
            label: 'Doctors',
            icon: Icons.medical_services_outlined,
            selectedIcon: Icons.medical_services,
          ),
          _NavItem(
            route: '/patient/appointments',
            label: 'Appointments',
            icon: Icons.event_note_outlined,
            selectedIcon: Icons.event_note,
          ),
          _NavItem(
            route: '/patient/reports',
            label: 'Reports',
            icon: Icons.description_outlined,
            selectedIcon: Icons.description,
          ),
          _NavItem(
            route: '/patient/lab-tests',
            label: 'Lab Tests',
            icon: Icons.science_outlined,
            selectedIcon: Icons.science,
          ),
          _NavItem(
            route: '/patient/staff',
            label: 'Medical Staff',
            icon: Icons.local_hospital_outlined,
            selectedIcon: Icons.local_hospital,
          ),
          _NavItem(
            route: '/patient/notifications',
            label: 'Notifications',
            icon: Icons.notifications_outlined,
            selectedIcon: Icons.notifications,
          ),
        ];
      case AppRole.doctor:
        return const [
          _NavItem(
            route: '/doctor/dashboard',
            label: 'Dashboard',
            icon: Icons.local_hospital_outlined,
            selectedIcon: Icons.local_hospital,
          ),
          _NavItem(
            route: '/doctor/prescriptions',
            label: 'Prescriptions',
            icon: Icons.description_outlined,
            selectedIcon: Icons.description,
          ),
          _NavItem(
            route: '/doctor/records',
            label: 'Records',
            icon: Icons.folder_shared_outlined,
            selectedIcon: Icons.folder_shared,
          ),
        ];
      case AppRole.admin:
        return const [
          _NavItem(
            route: '/admin/dashboard',
            label: 'Dashboard',
            icon: Icons.admin_panel_settings_outlined,
            selectedIcon: Icons.admin_panel_settings,
          ),
          _NavItem(
            route: '/admin/users',
            label: 'Users',
            icon: Icons.groups_outlined,
            selectedIcon: Icons.groups,
          ),
          _NavItem(
            route: '/admin/inventory',
            label: 'Inventory',
            icon: Icons.inventory_2_outlined,
            selectedIcon: Icons.inventory_2,
          ),
          _NavItem(
            route: '/admin/reports',
            label: 'Reports',
            icon: Icons.insights_outlined,
            selectedIcon: Icons.insights,
          ),
        ];
      case AppRole.lab:
        return const [
          _NavItem(
            route: '/lab/dashboard',
            label: 'Dashboard',
            icon: Icons.science_outlined,
            selectedIcon: Icons.science,
          ),
          _NavItem(
            route: '/lab/results',
            label: 'Results',
            icon: Icons.biotech_outlined,
            selectedIcon: Icons.biotech,
          ),
        ];
      case AppRole.dispenser:
        return const [
          _NavItem(
            route: '/dispenser/dashboard',
            label: 'Dashboard',
            icon: Icons.medication_outlined,
            selectedIcon: Icons.medication,
          ),
          _NavItem(
            route: '/dispenser/stock',
            label: 'Stock',
            icon: Icons.medical_services_outlined,
            selectedIcon: Icons.medical_services,
          ),
          _NavItem(
            route: '/dispenser/history',
            label: 'History',
            icon: Icons.history_outlined,
            selectedIcon: Icons.history,
          ),
        ];
      case AppRole.unknown:
        return const [
          _NavItem(
            route: '/home',
            label: 'Home',
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
          ),
        ];
    }
  }
}
