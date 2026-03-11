import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/charts/admin_analytics_chart.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/change_password_dialog.dart';
import '../../widgets/common/dashboard_shell.dart';
import '../../widgets/common/role_profile_form_card.dart';
import '../../utils/cloudinary_upload.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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
      context.read<RoleDashboardController>().loadAdmin();
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
    final phone = _phoneCtrl.text.trim();
    final qualification = _qualificationCtrl.text.trim();
    final designation = _designationCtrl.text.trim();

    if ([name, phone, qualification, designation].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields except email are required.')),
      );
      return;
    }

    final ok = await c.updateAdminProfile(
      name: name,
      phone: phone,
      qualification: qualification,
      designation: designation,
      profilePictureUrl: _profilePictureUrl,
    );

    if (!mounted) return;
    if (ok) {
      setState(() => _isEditingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin profile updated successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(c.error ?? 'Failed to update admin profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoleDashboardController>();
    final profile = c.adminProfile;
    _bindProfile(profile);

    return DashboardShell(
      child: c.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'Admin Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                RoleProfileFormCard(
                  title: 'Profile Information',
                  isEditing: _isEditingProfile,
                  isBusy: c.isLoading,
                  nameController: _nameCtrl,
                  emailController: _emailCtrl,
                  phoneController: _phoneCtrl,
                  qualificationController: _qualificationCtrl,
                  designationController: _designationCtrl,
                  emailEditable: false,
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
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Stat(
                      title: 'Total Users',
                      value: '${c.adminOverview?.totalUsers ?? 0}',
                    ),
                    _Stat(
                      title: 'Stock Items',
                      value: '${c.adminOverview?.totalStockItems ?? 0}',
                    ),
                    _Stat(
                      title: 'Total Patients',
                      value: '${c.adminAnalytics?.totalPatients ?? 0}',
                    ),
                    _Stat(
                      title: 'Medicines Dispensed',
                      value: '${c.adminAnalytics?.medicinesDispensed ?? 0}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (c.adminAnalytics != null)
                  AdminAnalyticsChart(
                    monthly: c.adminAnalytics!.monthlyBreakdown
                        .map((m) => ('M${m.month}', m.total))
                        .toList(),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Recent Audit Activity (24h)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Action')),
                    DataColumn(label: Text('Actor')),
                    DataColumn(label: Text('Target')),
                    DataColumn(label: Text('When')),
                  ],
                  rows: c.adminAudits
                      .map(
                        (a) => DataRow(
                          cells: [
                            DataCell(Text(a.action)),
                            DataCell(Text(a.adminName ?? '-')),
                            DataCell(Text(a.targetName ?? '-')),
                            DataCell(Text(a.createdAt.toString())),
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

class _Stat extends StatelessWidget {
  const _Stat({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
