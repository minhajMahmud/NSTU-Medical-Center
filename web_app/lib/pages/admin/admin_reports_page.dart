import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/charts/admin_analytics_chart.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
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
    final a = c.adminAnalytics;

    return DashboardShell(
      child: c.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'Admin • Reports',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                if (a != null)
                  AdminAnalyticsChart(
                    monthly: a.monthlyBreakdown
                        .map((m) => ('M${m.month}', m.total))
                        .toList(),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Top Medicines',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Medicine')),
                    DataColumn(label: Text('Used')),
                  ],
                  rows: (a?.topMedicines ?? const [])
                      .map(
                        (m) => DataRow(
                          cells: [
                            DataCell(Text(m.medicineName)),
                            DataCell(Text(m.used.toString())),
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
