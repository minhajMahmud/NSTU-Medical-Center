import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class DispenserDashboardPage extends StatefulWidget {
  const DispenserDashboardPage({super.key});

  @override
  State<DispenserDashboardPage> createState() => _DispenserDashboardPageState();
}

class _DispenserDashboardPageState extends State<DispenserDashboardPage> {
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
                  'Dispenser Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text('Welcome ${c.dispenserProfile?.name ?? ''}'),
                const SizedBox(height: 12),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Medicine')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Current Qty')),
                    DataColumn(label: Text('Min Qty')),
                  ],
                  rows: c.dispenserStock
                      .map(
                        (s) => DataRow(
                          cells: [
                            DataCell(Text(s.itemName)),
                            DataCell(Text(s.categoryName)),
                            DataCell(Text('${s.currentQuantity} ${s.unit}')),
                            DataCell(Text('${s.minimumStock} ${s.unit}')),
                          ],
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Dispense History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
