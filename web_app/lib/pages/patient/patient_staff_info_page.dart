import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/dashboard_shell.dart';

class PatientStaffInfoPage extends StatefulWidget {
  const PatientStaffInfoPage({super.key});

  @override
  State<PatientStaffInfoPage> createState() => _PatientStaffInfoPageState();
}

class _PatientStaffInfoPageState extends State<PatientStaffInfoPage> {
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
      child: c.isLoading && c.patientOnDutyStaff.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'On-duty Medical Staff',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Shift')),
                  ],
                  rows: c.patientOnDutyStaff
                      .map(
                        (s) => DataRow(
                          cells: [
                            DataCell(Text(s.staffName)),
                            DataCell(Text(s.staffRole.name)),
                            DataCell(Text('${s.shift.name} - ${s.shiftDate.toString().split(' ').first}')),
                          ],
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'University Ambulance Contacts',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                 AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Title')),
                    DataColumn(label: Text('Phone (EN)')),
                    DataColumn(label: Text('Phone (BN)')),
                    DataColumn(label: Text('Primary')),
                  ],
                  rows: c.patientAmbulanceContacts
                      .map(
                        (a) => DataRow(
                          cells: [
                            DataCell(Text(a.contactTitle)),
                            DataCell(Text(a.phoneEn)),
                            DataCell(Text(a.phoneBn)),
                             DataCell(
                              a.isPrimary
                                  ? const Icon(Icons.star, color: Colors.orange)
                                  : const SizedBox(),
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
