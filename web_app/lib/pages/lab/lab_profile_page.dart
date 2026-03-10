import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/dashboard_shell.dart';

class LabProfilePage extends StatefulWidget {
  const LabProfilePage({super.key});

  @override
  State<LabProfilePage> createState() => _LabProfilePageState();
}

class _LabProfilePageState extends State<LabProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RoleDashboardController>().loadLab();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoleDashboardController>();
    final summary = c.labSummary;

    return DashboardShell(
      child: c.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'Lab Profile',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0B5EA8), Color(0xFF0EA5E9)],
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.science,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NSTU Diagnostic Lab',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text('Lab Unit: lab1 • Role: Lab Technician'),
                              SizedBox(height: 4),
                              Text('Email: lab@nstu-medical.local'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _ProfileStat(
                      title: 'Today Pending',
                      value: '${summary?.todayPendingUploads ?? 0}',
                      icon: Icons.pending_actions,
                      color: const Color(0xFFE8F1FF),
                    ),
                    _ProfileStat(
                      title: 'Today Submitted',
                      value: '${summary?.todaySubmitted ?? 0}',
                      icon: Icons.task_alt,
                      color: const Color(0xFFDCFCE7),
                    ),
                    _ProfileStat(
                      title: 'Available Tests',
                      value:
                          '${c.labAvailableTests.where((e) => e.available).length}',
                      icon: Icons.biotech_outlined,
                      color: const Color(0xFFFCE7F3),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About this Lab',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This unit handles sample processing, report uploads, and quality checks. You can manage available tests, monitor queue pressure, and publish announcements from the side navigation.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color, child: Icon(icon)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(title),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
