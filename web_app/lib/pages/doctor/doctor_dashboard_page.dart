import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../utils/cloudinary_upload.dart';
import '../../widgets/common/change_password_dialog.dart';
import '../../widgets/common/dashboard_shell.dart';
import '../../widgets/common/role_profile_form_card.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _qualificationCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  bool _isEditingProfile = false;
  String? _profilePictureUrl;
  bool _isUploadingPicture = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RoleDashboardController>().loadDoctor();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _qualificationCtrl.dispose();
    _designationCtrl.dispose();
    super.dispose();
  }

  void _bindProfile(dynamic p) {
    if (_isEditingProfile) return;
    _nameCtrl.text = p?.name ?? '';
    _emailCtrl.text = p?.email ?? '';
    _phoneCtrl.text = p?.phone ?? '';
    _qualificationCtrl.text = p?.qualification ?? '';
    _designationCtrl.text = p?.designation ?? '';
    _profilePictureUrl = p?.profilePictureUrl;
  }

  Future<void> _uploadProfilePicture() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;

    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read selected image file.')),
      );
      return;
    }

    setState(() => _isUploadingPicture = true);
    final url = await CloudinaryUpload.uploadAuto(
      bytes: bytes,
      folder: 'profile_pictures',
      fileName: file.name,
    );
    if (!mounted) return;
    setState(() => _isUploadingPicture = false);

    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed. Please try again.')),
      );
      return;
    }

    setState(() => _profilePictureUrl = url);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile image uploaded.')));
  }

  Future<void> _saveProfile(RoleDashboardController c) async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final qualification = _qualificationCtrl.text.trim();
    final designation = _designationCtrl.text.trim();

    if ([
      name,
      email,
      phone,
      qualification,
      designation,
    ].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required.')));
      return;
    }

    final ok = await c.updateDoctorProfile(
      name: name,
      email: email,
      phone: phone,
      qualification: qualification,
      designation: designation,
      profilePictureUrl: _profilePictureUrl,
    );

    if (!mounted) return;
    if (ok) {
      setState(() => _isEditingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor profile updated successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(c.error ?? 'Failed to update doctor profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoleDashboardController>();
    final profile = c.doctorProfile;
    final home = c.doctorHome;
    _bindProfile(profile);

    final activities = _buildActivities(home);
    final reviewedReports = home?.reviewedReports ?? const [];

    return DashboardShell(
      child: c.isLoading && home == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _DoctorWelcomeHeader(
                  home: home,
                  profilePictureUrl: _profilePictureUrl,
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _OverviewCard(
                      title: 'Today',
                      icon: Icons.calendar_month_rounded,
                      value: home == null
                          ? '-'
                          : DateFormat('d/M/yyyy').format(home.today.toLocal()),
                      deltaText: _deltaText(
                        current: home?.todayPrescriptions ?? 0,
                        previous: home?.yesterdayPrescriptions ?? 0,
                        positiveLabel: 'vs. yesterday',
                        negativeLabel: 'vs. yesterday',
                      ),
                      deltaPositive:
                          (home?.todayPrescriptions ?? 0) >=
                          (home?.yesterdayPrescriptions ?? 0),
                    ),
                    _OverviewCard(
                      title: 'Last Month Prescriptions',
                      icon: Icons.medical_information_rounded,
                      value: '${home?.lastMonthPrescriptions ?? 0}',
                      deltaText: _deltaText(
                        current: home?.lastMonthPrescriptions ?? 0,
                        previous: home?.previousMonthPrescriptions ?? 0,
                        positiveLabel: 'vs. prev month',
                        negativeLabel: 'vs. prev month',
                      ),
                      deltaPositive:
                          (home?.lastMonthPrescriptions ?? 0) >=
                          (home?.previousMonthPrescriptions ?? 0),
                    ),
                    _OverviewCard(
                      title: 'Last Week Prescriptions',
                      icon: Icons.vaccines_rounded,
                      value: '${home?.lastWeekPrescriptions ?? 0}',
                      deltaText: _deltaText(
                        current: home?.lastWeekPrescriptions ?? 0,
                        previous: home?.previousWeekPrescriptions ?? 0,
                        positiveLabel: 'vs. last week',
                        negativeLabel: 'vs. last week',
                      ),
                      deltaPositive:
                          (home?.lastWeekPrescriptions ?? 0) >=
                          (home?.previousWeekPrescriptions ?? 0),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _ReportsPanel(
                        reports: reviewedReports,
                        onRefresh: () => c.loadDoctor(),
                        onArchive: () => context.go('/doctor/reports'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _RecentActivityPanel(activities: activities),
                          const SizedBox(height: 16),
                          _NextFollowUpCard(
                            home: home,
                            profilePictureUrl: _profilePictureUrl,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                RoleProfileFormCard(
                  title: 'Profile Information',
                  isEditing: _isEditingProfile,
                  isBusy: c.isLoading,
                  nameController: _nameCtrl,
                  emailController: _emailCtrl,
                  phoneController: _phoneCtrl,
                  qualificationController: _qualificationCtrl,
                  designationController: _designationCtrl,
                  profileImageUrl: _profilePictureUrl,
                  isUploadingImage: _isUploadingPicture,
                  onUploadPicture: _isEditingProfile
                      ? _uploadProfilePicture
                      : null,
                  onChangePassword: () {
                    showChangePasswordDialog(
                      context: context,
                      onSubmit: (current, next) => c.changeMyPassword(
                        currentPassword: current,
                        newPassword: next,
                      ),
                      getErrorMessage: () => c.error,
                    );
                  },
                  onToggleEditOrSave: () {
                    if (_isEditingProfile) {
                      _saveProfile(c);
                    } else {
                      setState(() => _isEditingProfile = true);
                    }
                  },
                ),
              ],
            ),
    );
  }

  String _deltaText({
    required int current,
    required int previous,
    required String positiveLabel,
    required String negativeLabel,
  }) {
    if (previous == 0) {
      if (current == 0) return '0% $positiveLabel';
      return '+100% $positiveLabel';
    }
    final percent = ((current - previous) / previous) * 100;
    final sign = percent >= 0 ? '+' : '';
    final label = percent >= 0 ? positiveLabel : negativeLabel;
    return '$sign${percent.toStringAsFixed(0)}% $label';
  }

  List<_ActivityItemData> _buildActivities(dynamic home) {
    final items = <_ActivityItemData>[];
    for (final item in home?.recent ?? const []) {
      items.add(
        _ActivityItemData(
          title: item.title,
          subtitle: item.subtitle,
          timeAgo: item.timeAgo,
          icon: Icons.medical_services_rounded,
          color: const Color(0xFFE8F1FF),
          iconColor: const Color(0xFF2563EB),
        ),
      );
    }
    for (final report in home?.reviewedReports ?? const []) {
      items.add(
        _ActivityItemData(
          title: report.type.isEmpty ? 'New Lab Result' : report.type,
          subtitle: report.uploadedByName.isEmpty
              ? 'Diagnostic report received'
              : 'Patient: ${report.uploadedByName}',
          timeAgo: report.timeAgo,
          icon: Icons.science_rounded,
          color: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF7C3AED),
        ),
      );
    }
    if (items.isEmpty) {
      items.add(
        const _ActivityItemData(
          title: 'No recent activity',
          subtitle: 'New prescriptions and reports will appear here.',
          timeAgo: '',
          icon: Icons.history_toggle_off_rounded,
          color: Color(0xFFF1F5F9),
          iconColor: Color(0xFF64748B),
        ),
      );
    }
    return items.take(4).toList();
  }
}

class _DoctorWelcomeHeader extends StatelessWidget {
  const _DoctorWelcomeHeader({
    required this.home,
    required this.profilePictureUrl,
  });

  final dynamic home;
  final String? profilePictureUrl;

  @override
  Widget build(BuildContext context) {
    final name = (home?.doctorName as String?)?.trim();
    final designation = (home?.doctorDesignation as String?)?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${name?.isNotEmpty == true ? 'Dr. $name' : 'Doctor'}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                designation?.isNotEmpty == true
                    ? 'Here is what\'s happening at NSTU Medical Center today • $designation'
                    : 'Here is what\'s happening at NSTU Medical Center today.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFE8F1FF),
          backgroundImage:
              profilePictureUrl != null && profilePictureUrl!.isNotEmpty
              ? NetworkImage(profilePictureUrl!)
              : (home?.doctorProfilePictureUrl != null &&
                    (home.doctorProfilePictureUrl as String).isNotEmpty)
              ? NetworkImage(home.doctorProfilePictureUrl as String)
              : null,
          child:
              ((profilePictureUrl == null || profilePictureUrl!.isEmpty) &&
                  (home?.doctorProfilePictureUrl == null ||
                      (home.doctorProfilePictureUrl as String).isEmpty))
              ? const Icon(Icons.person, size: 28)
              : null,
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.icon,
    required this.value,
    required this.deltaText,
    required this.deltaPositive,
  });

  final String title;
  final IconData icon;
  final String value;
  final String deltaText;
  final bool deltaPositive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    deltaPositive ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: deltaPositive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      deltaText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: deltaPositive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportsPanel extends StatelessWidget {
  const _ReportsPanel({
    required this.reports,
    required this.onRefresh,
    required this.onArchive,
  });

  final List<dynamic> reports;
  final VoidCallback onRefresh;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final hasReports = reports.isNotEmpty;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reports',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Summary for the last 24 hours',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(onPressed: onArchive, child: const Text('View all')),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasReports)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 48,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: Icon(
                        Icons.monitor_heart_outlined,
                        color: Colors.blueGrey.shade400,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'No reports found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'There are no diagnostic reports to review from the last 24 hours.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      children: [
                        FilledButton(
                          onPressed: onRefresh,
                          child: const Text('Refresh'),
                        ),
                        OutlinedButton(
                          onPressed: onArchive,
                          child: const Text('Check Archive'),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              ...reports
                  .take(5)
                  .map(
                    (report) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE8F1FF),
                        child: Icon(
                          Icons.science_rounded,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      title: Text(
                        report.type.isEmpty ? 'Lab Result' : report.type,
                      ),
                      subtitle: Text(
                        report.uploadedByName.isEmpty
                            ? report.timeAgo
                            : 'Patient: ${report.uploadedByName} • ${report.timeAgo}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityPanel extends StatelessWidget {
  const _RecentActivityPanel({required this.activities});

  final List<_ActivityItemData> activities;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ...activities.map(
              (activity) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: activity.color,
                      child: Icon(
                        activity.icon,
                        color: activity.iconColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activity.subtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: const Color(0xFF64748B)),
                          ),
                          if (activity.timeAgo.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              activity.timeAgo,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: const Color(0xFF94A3B8)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Load more activity'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextFollowUpCard extends StatelessWidget {
  const _NextFollowUpCard({
    required this.home,
    required this.profilePictureUrl,
  });

  final dynamic home;
  final String? profilePictureUrl;

  @override
  Widget build(BuildContext context) {
    final patientName = (home?.nextFollowUpPatientName as String?)?.trim();
    final note = (home?.nextFollowUpNote as String?)?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Follow-up',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white24,
                backgroundImage:
                    profilePictureUrl != null && profilePictureUrl!.isNotEmpty
                    ? NetworkImage(profilePictureUrl!)
                    : null,
                child: profilePictureUrl == null || profilePictureUrl!.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName?.isNotEmpty == true
                          ? patientName!
                          : 'No follow-up scheduled',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      note?.isNotEmpty == true
                          ? note!
                          : 'Create a prescription with next visit details to see it here.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityItemData {
  const _ActivityItemData({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final String timeAgo;
  final IconData icon;
  final Color color;
  final Color iconColor;
}
