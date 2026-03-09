import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/utils/role_utils.dart';

class AppTopNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AppTopNavigationBar({super.key, this.showMenuButton = false});

  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final dashboardPath = RoleUtils.dashboardPathForRole(auth.appRole);

    return AppBar(
      title: const Text('NSTU Medical Center'),
      leading: showMenuButton
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : null,
      actions: [
        TextButton(
          onPressed: () => context.go('/home'),
          child: const Text('Home'),
        ),
        TextButton(
          onPressed: () => context.go(dashboardPath),
          child: const Text('Dashboard'),
        ),
        if (auth.isAuthenticated)
          TextButton(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Logout'),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
