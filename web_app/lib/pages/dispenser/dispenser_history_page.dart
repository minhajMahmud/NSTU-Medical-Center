import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class DispenserHistoryPage extends StatefulWidget {
  const DispenserHistoryPage({super.key});

  @override
  State<DispenserHistoryPage> createState() => _DispenserHistoryPageState();
}

class _DispenserHistoryPageState extends State<DispenserHistoryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RoleDashboardController>().loadDispenser();
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
                  'Dispenser • History',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Dispense ID')),
                    DataColumn(label: Text('Patient')),
                    DataColumn(label: Text('Prescription')),
                    DataColumn(label: Text('Date')),
                  ],
                  rows: c.dispenserHistory
                      .map(
                        (h) => DataRow(
                          cells: [
                            DataCell(Text(h.dispenseId.toString())),
                            DataCell(Text(h.patientName)),
                            DataCell(Text(h.prescriptionId.toString())),
                            DataCell(
                              Text(
                                DateFormat('dd MMM yyyy').format(h.dispensedAt),
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
