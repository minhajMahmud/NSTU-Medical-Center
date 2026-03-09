import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/charts/admin_analytics_chart.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RoleDashboardController>().loadAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoleDashboardController>();

    return DashboardShell(
      child: c.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'Admin Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Stat(
                      title: 'Total Users',
                      value: '${c.adminOverview?.totalUsers ?? 0}',
                    ),
                    _Stat(
                      title: 'Stock Items',
                      value: '${c.adminOverview?.totalStockItems ?? 0}',
                    ),
                    _Stat(
                      title: 'Total Patients',
                      value: '${c.adminAnalytics?.totalPatients ?? 0}',
                    ),
                    _Stat(
                      title: 'Medicines Dispensed',
                      value: '${c.adminAnalytics?.medicinesDispensed ?? 0}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (c.adminAnalytics != null)
                  AdminAnalyticsChart(
                    monthly: c.adminAnalytics!.monthlyBreakdown
                        .map((m) => ('M${m.month}', m.total))
                        .toList(),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Recent Audit Activity (24h)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Action')),
                    DataColumn(label: Text('Actor')),
                    DataColumn(label: Text('Target')),
                    DataColumn(label: Text('When')),
                  ],
                  rows: c.adminAudits
                      .map(
                        (a) => DataRow(
                          cells: [
                            DataCell(Text(a.action)),
                            DataCell(Text(a.adminName ?? '-')),
                            DataCell(Text(a.targetName ?? '-')),
                            DataCell(Text(a.createdAt.toString())),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
