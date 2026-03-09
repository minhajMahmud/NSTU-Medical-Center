import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class MedicalReportsPage extends StatefulWidget {
  const MedicalReportsPage({super.key});

  @override
  State<MedicalReportsPage> createState() => _MedicalReportsPageState();
}

class _MedicalReportsPageState extends State<MedicalReportsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final c = context.read<RoleDashboardController>();
      if (c.patientReports.isEmpty) c.loadPatient();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoleDashboardController>();

    return DashboardShell(
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Medical Reports',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'This feature uses finalizeReportUpload to attach external test results and automatically notify the assigned doctor.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload External Report'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppDataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Test Name')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Status')),
            ],
            rows: c.patientReports
                .map(
                  (r) => DataRow(
                    cells: [
                      DataCell(Text(r.id.toString())),
                      DataCell(Text(r.testName)),
                      DataCell(Text(DateFormat('dd MMM yyyy').format(r.date))),
                      DataCell(Text(r.isUploaded ? 'Uploaded' : 'Pending')),
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
