import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/cards/appointment_card.dart';
import '../../widgets/common/dashboard_shell.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final c = context.read<RoleDashboardController>();
      if (c.patientAppointments.isEmpty) c.loadPatient();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoleDashboardController>();

    return DashboardShell(
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Appointments',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Appointment booking can be connected to your doctor/patient creation flow next.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Book Appointment'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...c.patientAppointments.map((a) => AppointmentCard(appointment: a)),
        ],
      ),
    );
  }
}
