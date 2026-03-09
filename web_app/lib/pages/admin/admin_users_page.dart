import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
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
                  'Admin • Users',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Active')),
                  ],
                  rows: c.adminUsers
                      .map(
                        (u) => DataRow(
                          cells: [
                            DataCell(Text(u.name)),
                            DataCell(Text(u.email)),
                            DataCell(Text(u.role)),
                            DataCell(Text(u.phone ?? '-')),
                            DataCell(Text(u.active ? 'Yes' : 'No')),
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
