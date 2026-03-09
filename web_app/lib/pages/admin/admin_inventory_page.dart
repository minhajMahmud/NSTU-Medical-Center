import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class AdminInventoryPage extends StatefulWidget {
  const AdminInventoryPage({super.key});

  @override
  State<AdminInventoryPage> createState() => _AdminInventoryPageState();
}

class _AdminInventoryPageState extends State<AdminInventoryPage> {
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

    return DashboardShell(
      child: c.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'Admin • Inventory',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Item')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Current')),
                    DataColumn(label: Text('Minimum')),
                    DataColumn(label: Text('Restock by Dispenser')),
                  ],
                  rows: c.adminInventory
                      .map(
                        (i) => DataRow(
                          cells: [
                            DataCell(Text(i.itemName)),
                            DataCell(Text(i.categoryName)),
                            DataCell(Text('${i.currentQuantity} ${i.unit}')),
                            DataCell(Text('${i.minimumStock} ${i.unit}')),
                            DataCell(
                              Text(i.canRestockDispenser ? 'Yes' : 'No'),
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
