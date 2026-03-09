import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/dashboard_shell.dart';

class PatientNotificationsPage extends StatefulWidget {
  const PatientNotificationsPage({super.key});

  @override
  State<PatientNotificationsPage> createState() => _PatientNotificationsPageState();
}

class _PatientNotificationsPageState extends State<PatientNotificationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RoleDashboardController>().loadPatient();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoleDashboardController>();

    return DashboardShell(
      child: c.isLoading && c.patientNotifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                if (c.patientNotifications.isEmpty)
                  const Text('No recent notifications.')
                else
                  ...c.patientNotifications.map(
                    (n) => Card(
                      child: ListTile(
                        leading: Icon(
                          n.isRead ? Icons.notifications_none : Icons.notifications_active,
                          color: n.isRead ? Colors.grey : Colors.blue,
                        ),
                        title: Text(n.title),
                        subtitle: Text(n.message),
                        trailing: Text(
                          DateFormat('dd MMM hh:mm a').format(n.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
