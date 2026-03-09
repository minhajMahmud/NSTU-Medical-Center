import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
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
                  'Doctor Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Stat(
                      title: 'Last Week Prescriptions',
                      value: (c.doctorHome?.lastWeekPrescriptions ?? 0)
                          .toString(),
                    ),
                    _Stat(
                      title: 'Last Month Prescriptions',
                      value: (c.doctorHome?.lastMonthPrescriptions ?? 0)
                          .toString(),
                    ),
                    _Stat(
                      title: 'Reviewed Reports',
                      value: (c.doctorHome?.reviewedReports.length ?? 0)
                          .toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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

class _Stat extends StatelessWidget {
  const _Stat({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
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
