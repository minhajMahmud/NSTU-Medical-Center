import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/cards/dashboard_stats.dart';
import '../../widgets/common/dashboard_shell.dart';

class PatientDashboardPage extends StatefulWidget {
  const PatientDashboardPage({super.key});

  @override
  State<PatientDashboardPage> createState() => _PatientDashboardPageState();
}

class _PatientDashboardPageState extends State<PatientDashboardPage> {
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
    final controller = context.watch<RoleDashboardController>();

    return DashboardShell(
      child: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                DashboardStats(
                  doctorCount: controller.patientDoctors.length,
                  appointmentCount: controller.patientAppointments.length,
                  reportCount: controller.patientReports.length,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your patient portal is live with real backend data for doctors, appointments, and reports.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
    );
  }
}
