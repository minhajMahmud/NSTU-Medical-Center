import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class PatientLabTestsPage extends StatefulWidget {
  const PatientLabTestsPage({super.key});

  @override
  State<PatientLabTestsPage> createState() => _PatientLabTestsPageState();
}

class _PatientLabTestsPageState extends State<PatientLabTestsPage> {
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
      child: c.isLoading && c.patientLabTests.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'Lab Tests Availability',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Test Name')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Availability')),
                  ],
                  rows: c.patientLabTests
                      .map(
                        (t) => DataRow(
                          cells: [
                            DataCell(Text(t.testName)),
                            DataCell(Text(t.description)),
                            DataCell(
                              t.available
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.cancel, color: Colors.red),
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
