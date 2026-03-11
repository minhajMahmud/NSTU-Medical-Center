import 'package:flutter/material.dart';

class AppTopNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AppTopNavigationBar({super.key, this.showMenuButton = false});

  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
