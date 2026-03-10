import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/dashboard_shell.dart';

class LabAnalyticsPage extends StatefulWidget {
  const LabAnalyticsPage({super.key});

  @override
  State<LabAnalyticsPage> createState() => _LabAnalyticsPageState();
}

class _LabAnalyticsPageState extends State<LabAnalyticsPage> {
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

    final total = c.labResults.length;
    final submitted = c.labResults.where((r) => r.submittedAt != null).length;
    final pending = total - submitted;

    final urgent = c.labResults
        .where((r) => r.patientType.toUpperCase().contains('URGENT'))
        .length;

    final byType = <String, int>{};
    for (final r in c.labResults) {
      byType.update(r.patientType, (v) => v + 1, ifAbsent: () => 1);
    }

    final sortedTypes = byType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return DashboardShell(
      child: c.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'Analytics',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard(
                      title: 'Total Results',
                      value: '$total',
                      icon: Icons.description_outlined,
                    ),
                    _MetricCard(
                      title: 'Submitted',
                      value: '$submitted',
                      icon: Icons.check_circle_outline,
                    ),
                    _MetricCard(
                      title: 'Pending',
                      value: '$pending',
                      icon: Icons.pending_actions,
                    ),
                    _MetricCard(
                      title: 'Urgent Cases',
                      value: '$urgent',
                      icon: Icons.priority_high,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient Type Distribution',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        if (sortedTypes.isEmpty)
                          const Text('No analytics data available yet.')
                        else
                          ...sortedTypes.map((entry) {
                            final ratio = total == 0
                                ? 0.0
                                : entry.value / total;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(entry.key)),
                                      Text('${entry.value}'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFE8F1FF),
                child: Icon(icon),
              ),
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
