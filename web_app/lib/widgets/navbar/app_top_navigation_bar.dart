import 'package:backend_client/backend_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';

class AppTopNavigationBar extends StatefulWidget
    implements PreferredSizeWidget {
  const AppTopNavigationBar({super.key, this.showMenuButton = false});

  final bool showMenuButton;

  @override
  State<AppTopNavigationBar> createState() => _AppTopNavigationBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppTopNavigationBarState extends State<AppTopNavigationBar> {
  bool _expandToday = true;
  bool _expandEarlier = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RoleDashboardController>().startNotificationRealtimeSync();
    });
  }

  String _displayMessage(String message) {
    return message
        .replaceAll(RegExp(r'\s*\[route:[^\]]+\]', caseSensitive: false), '')
        .trim();
  }

  String _targetRoute(BuildContext context, String title, String message) {
    final routeToken = RegExp(
      r'\[route:([^\]]+)\]',
      caseSensitive: false,
    ).firstMatch(message)?.group(1)?.trim();
    if (routeToken != null && routeToken.startsWith('/')) return routeToken;
    final currentPath = GoRouterState.of(context).uri.path;
    if (currentPath.startsWith('/doctor')) return '/doctor/reports';
    return '/patient/reports';
  }

  ({IconData icon, Color color, String type}) _notificationStyle(
    String title,
    String message,
  ) {
    final text = '${title.toLowerCase()} ${message.toLowerCase()}';
    if (text.contains('payment') || text.contains('paid')) {
      return (
        icon: Icons.payments_rounded,
        color: Colors.green,
        type: 'Payment',
      );
    }
    if (text.contains('report') || text.contains('lab result')) {
      return (
        icon: Icons.science_rounded,
        color: Colors.deepPurple,
        type: 'Test Report',
      );
    }
    if (text.contains('prescription') || text.contains('medicine')) {
      return (
        icon: Icons.description_rounded,
        color: Colors.orange,
        type: 'Prescription',
      );
    }
    if (text.contains('appointment')) {
      return (
        icon: Icons.calendar_today_rounded,
        color: Colors.blue,
        type: 'Appointment',
      );
    }
    return (
      icon: Icons.notifications_rounded,
      color: Colors.blueGrey,
      type: 'Notification',
    );
  }

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  Widget _buildNotificationTile(
    BuildContext context,
    RoleDashboardController ctrl,
    NotificationInfo n,
  ) {
    final style = _notificationStyle(n.title, n.message);
    final cleanMessage = _displayMessage(n.message);
    return ListTile(
      dense: true,
      tileColor: n.isRead
          ? null
          : Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.18),
      leading: CircleAvatar(
        backgroundColor: style.color.withValues(alpha: 0.15),
        child: Icon(style.icon, color: style.color, size: 20),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              n.title,
              style: TextStyle(
                fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!n.isRead)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 2),
          Text(cleanMessage),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              style.type,
              style: TextStyle(
                color: style.color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      trailing: Text(
        _timeAgo(n.createdAt),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      isThreeLine: true,
      onTap: () async {
        if (!n.isRead) {
          await ctrl.markNotificationAsRead(n.notificationId);
        }
        if (!context.mounted) return;
        final route = _targetRoute(context, n.title, n.message);
        Navigator.of(context).pop();
        if (!mounted) return;
        this.context.go(route);
      },
    );
  }

  Future<void> _openNotificationsPanel(BuildContext context) async {
    final c = context.read<RoleDashboardController>();
    await c.refreshNotifications(silent: true);
    if (!context.mounted) return;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss notifications',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (ctx, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        );
      },
      pageBuilder: (ctx, _, __) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 8,
            child: SizedBox(
              width: 380,
              height: double.infinity,
              child: SafeArea(
                child: Consumer<RoleDashboardController>(
                  builder: (_, ctrl, __) {
                    final sorted = [...ctrl.patientNotifications]
                      ..sort((a, b) {
                        final unreadPriority = (a.isRead ? 1 : 0).compareTo(
                          b.isRead ? 1 : 0,
                        );
                        if (unreadPriority != 0) return unreadPriority;
                        return b.createdAt.compareTo(a.createdAt);
                      });

                    final todayItems = sorted
                        .where((n) => _isToday(n.createdAt))
                        .toList();
                    final earlierItems = sorted
                        .where((n) => !_isToday(n.createdAt))
                        .toList();

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
                          child: Row(
                            children: [
                              Text(
                                'Notifications',
                                style: Theme.of(ctx).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: sorted.isEmpty
                                    ? null
                                    : () => ctrl.markAllNotificationsAsRead(),
                                icon: const Icon(Icons.done_all, size: 18),
                                label: const Text('Mark all read'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                tooltip: 'Close',
                                onPressed: () => Navigator.of(ctx).pop(),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: sorted.isEmpty
                              ? const Center(
                                  child: Text('No notifications yet.'),
                                )
                              : ListView(
                                  children: [
                                    if (todayItems.isNotEmpty) ...[
                                      ListTile(
                                        dense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                        title: Text(
                                          'Today',
                                          style: Theme.of(ctx)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        trailing: IconButton(
                                          tooltip: _expandToday
                                              ? 'Collapse today'
                                              : 'Expand today',
                                          onPressed: () => setState(
                                            () => _expandToday = !_expandToday,
                                          ),
                                          icon: Icon(
                                            _expandToday
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                          ),
                                        ),
                                      ),
                                      if (_expandToday)
                                        ...todayItems.map(
                                          (n) => Column(
                                            children: [
                                              _buildNotificationTile(
                                                ctx,
                                                ctrl,
                                                n,
                                              ),
                                              const Divider(height: 1),
                                            ],
                                          ),
                                        ),
                                    ],
                                    if (earlierItems.isNotEmpty) ...[
                                      ListTile(
                                        dense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                        title: Text(
                                          'Earlier',
                                          style: Theme.of(ctx)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        trailing: IconButton(
                                          tooltip: _expandEarlier
                                              ? 'Collapse earlier'
                                              : 'Expand earlier',
                                          onPressed: () => setState(
                                            () => _expandEarlier =
                                                !_expandEarlier,
                                          ),
                                          icon: Icon(
                                            _expandEarlier
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                          ),
                                        ),
                                      ),
                                      if (_expandEarlier)
                                        ...earlierItems.map(
                                          (n) => Column(
                                            children: [
                                              _buildNotificationTile(
                                                ctx,
                                                ctrl,
                                                n,
                                              ),
                                              const Divider(height: 1),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoleDashboardController>();
    final unread = c.unreadNotificationCount;

    return AppBar(
      title: const Text('NSTU Medical Center'),
      leading: widget.showMenuButton
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : null,
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => _openNotificationsPanel(context),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              TweenAnimationBuilder<double>(
                key: ValueKey<int>(unread),
                tween: Tween<double>(begin: 1.22, end: 1.0),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                child: const Icon(Icons.notifications_outlined),
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
              ),
              if (unread > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 16,
                    ),
                    child: Text(
                      unread > 99 ? '99+' : unread.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}
