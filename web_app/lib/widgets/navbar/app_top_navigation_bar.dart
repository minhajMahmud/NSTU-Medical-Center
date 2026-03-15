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
  ({IconData icon, Color color, String type}) _notificationStyle(
    BuildContext context,
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
        color: Colors.blue,
        type: 'Prescription',
      );
    }
    return (
      icon: Icons.notifications_active,
      color: Theme.of(context).colorScheme.primary,
      type: 'Update',
    );
  }

  String _targetRoute(String title, String message) {
    final text = '${title.toLowerCase()} ${message.toLowerCase()}';
    if (text.contains('payment') || text.contains('paid')) {
      return '/patient/payments';
    }
    if (text.contains('report') || text.contains('lab result')) {
      return '/patient/reports';
    }
    if (text.contains('prescription') || text.contains('medicine')) {
      return '/patient/reports';
    }
    return '/patient/notifications';
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return '1d ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(dateTime);
  }

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  Widget _buildNotificationTile(
    BuildContext context,
    RoleDashboardController ctrl,
    NotificationInfo n,
  ) {
    final style = _notificationStyle(context, n.title, n.message);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: style.color.withValues(alpha: n.isRead ? 0.12 : 0.18),
        child: Icon(
          n.isRead ? Icons.notifications_none : style.icon,
          color: n.isRead ? Colors.grey : style.color,
          size: 20,
        ),
      ),
      title: Text(
        n.title,
        style: TextStyle(
          fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(n.message),
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
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _timeAgo(n.createdAt),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('hh:mm a').format(n.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () async {
        if (!n.isRead) {
          await ctrl.markNotificationAsRead(n.notificationId);
        }
        if (!context.mounted) return;
        final route = _targetRoute(n.title, n.message);
        Navigator.of(context).pop();
        if (!mounted) return;
        this.context.go(route);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RoleDashboardController>().startNotificationRealtimeSync();
    });
  }

  Future<void> _openNotificationsPanel(BuildContext context) async {
    final c = context.read<RoleDashboardController>();
    await c.refreshNotifications(silent: true);
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.65,
            child: Consumer<RoleDashboardController>(
              builder: (_, ctrl, __) {
                final items = ctrl.patientNotifications;
                final todayItems = items
                    .where((n) => _isToday(n.createdAt))
                    .toList();
                final earlierItems = items
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
                            style: Theme.of(sheetContext).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: items.isEmpty
                                ? null
                                : () => ctrl.markAllNotificationsAsRead(),
                            icon: const Icon(Icons.done_all, size: 18),
                            label: const Text('Mark all read'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: items.isEmpty
                          ? const Center(child: Text('No notifications yet.'))
                          : ListView(
                              children: [
                                if (todayItems.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      12,
                                      16,
                                      6,
                                    ),
                                    child: Text(
                                      'Today',
                                      style: Theme.of(sheetContext)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  ...todayItems.map(
                                    (n) => Column(
                                      children: [
                                        _buildNotificationTile(
                                          sheetContext,
                                          ctrl,
                                          n,
                                        ),
                                        const Divider(height: 1),
                                      ],
                                    ),
                                  ),
                                ],
                                if (earlierItems.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      12,
                                      16,
                                      6,
                                    ),
                                    child: Text(
                                      'Earlier',
                                      style: Theme.of(sheetContext)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  ...earlierItems.map(
                                    (n) => Column(
                                      children: [
                                        _buildNotificationTile(
                                          sheetContext,
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
              const Icon(Icons.notifications_outlined),
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
