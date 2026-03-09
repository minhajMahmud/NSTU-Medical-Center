import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class LabDashboardPage extends StatefulWidget {
  const LabDashboardPage({super.key});

  @override
  State<LabDashboardPage> createState() => _LabDashboardPageState();
}

class _LabDashboardPageState extends State<LabDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RoleDashboardController>().loadLab();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoleDashboardController>();
    final summary = c.labSummary;

    return DashboardShell(
      child: c.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'Lab Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Stat(
                      title: 'Today Total',
                      value: '${summary?.todayTotal ?? 0}',
                    ),
                    _Stat(
                      title: 'Today Submitted',
                      value: '${summary?.todaySubmitted ?? 0}',
                    ),
                    _Stat(
                      title: 'Today Pending',
                      value: '${summary?.todayPendingUploads ?? 0}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Result ID')),
                    DataColumn(label: Text('Patient')),
                    DataColumn(label: Text('Mobile')),
                    DataColumn(label: Text('Uploaded')),
                    DataColumn(label: Text('Created')),
                  ],
                  rows: c.labHistory
                      .map(
                        (h) => DataRow(
                          cells: [
                            DataCell(Text(h.resultId.toString())),
                            DataCell(Text(h.patientName)),
                            DataCell(Text(h.mobileNumber)),
                            DataCell(Text(h.isUploaded ? 'Yes' : 'No')),
                            DataCell(
                              Text(
                                h.createdAt == null
                                    ? '-'
                                    : DateFormat(
                                        'dd MMM yyyy',
                                      ).format(h.createdAt!),
                              ),
                            ),
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
