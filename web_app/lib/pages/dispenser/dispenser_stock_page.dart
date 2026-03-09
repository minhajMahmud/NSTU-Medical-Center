import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class DispenserStockPage extends StatefulWidget {
  const DispenserStockPage({super.key});

  @override
  State<DispenserStockPage> createState() => _DispenserStockPageState();
}

class _DispenserStockPageState extends State<DispenserStockPage> {
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
                  'Dispenser • Stock',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Item')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Current')),
                    DataColumn(label: Text('Minimum')),
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
              ],
            ),
    );
  }
}
