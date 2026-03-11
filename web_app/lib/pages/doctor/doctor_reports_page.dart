import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class DoctorReportsPage extends StatefulWidget {
  const DoctorReportsPage({super.key});

  @override
  State<DoctorReportsPage> createState() => _DoctorReportsPageState();
}

class _DoctorReportsPageState extends State<DoctorReportsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RoleDashboardController>().loadDoctor();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoleDashboardController>();
    final reports = c.doctorHome?.reviewedReports ?? const [];

    return DashboardShell(
      child: c.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'Doctor • Reports',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Report Type')),
                    DataColumn(label: Text('Patient')),
                    DataColumn(label: Text('Prescription')),
                    DataColumn(label: Text('Time')),
                  ],
                  rows: reports
                      .map(
                        (r) => DataRow(
                          cells: [
                            DataCell(
                              Text(r.type.isEmpty ? 'Lab Result' : r.type),
                            ),
                            DataCell(
                              Text(
                                r.uploadedByName.isEmpty
                                    ? '-'
                                    : r.uploadedByName,
                              ),
                            ),
                            DataCell(Text(r.prescriptionId?.toString() ?? '-')),
                            DataCell(Text(r.timeAgo)),
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
