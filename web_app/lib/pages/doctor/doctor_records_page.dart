import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class DoctorRecordsPage extends StatefulWidget {
  const DoctorRecordsPage({super.key});

  @override
  State<DoctorRecordsPage> createState() => _DoctorRecordsPageState();
}

class _DoctorRecordsPageState extends State<DoctorRecordsPage> {
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

    return DashboardShell(
      child: c.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'Doctor • Patients',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Title')),
                    DataColumn(label: Text('Subtitle')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Time Ago')),
                  ],
                  rows: (c.doctorHome?.recent ?? const [])
                      .map(
                        (r) => DataRow(
                          cells: [
                            DataCell(Text(r.title)),
                            DataCell(Text(r.subtitle)),
                            DataCell(Text(r.type)),
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
