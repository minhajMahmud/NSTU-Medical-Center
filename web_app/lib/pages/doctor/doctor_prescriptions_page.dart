import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class DoctorPrescriptionsPage extends StatefulWidget {
  const DoctorPrescriptionsPage({super.key});

  @override
  State<DoctorPrescriptionsPage> createState() =>
      _DoctorPrescriptionsPageState();
}

class _DoctorPrescriptionsPageState extends State<DoctorPrescriptionsPage> {
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
                  'Doctor • Prescriptions',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Prescription ID')),
                    DataColumn(label: Text('Patient')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Date')),
                  ],
                  rows: c.doctorPrescriptionList
                      .map(
                        (p) => DataRow(
                          cells: [
                            DataCell(Text(p.prescriptionId.toString())),
                            DataCell(Text(p.name)),
                            DataCell(Text(p.mobileNumber ?? '-')),
                            DataCell(
                              Text(
                                p.prescriptionDate == null
                                    ? '-'
                                    : DateFormat(
                                        'dd MMM yyyy',
                                      ).format(p.prescriptionDate!),
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
