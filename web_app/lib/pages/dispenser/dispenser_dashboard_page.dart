import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/app_data_table.dart';
import '../../widgets/common/change_password_dialog.dart';
import '../../widgets/common/dashboard_shell.dart';
import '../../widgets/common/role_profile_form_card.dart';
import '../../utils/cloudinary_upload.dart';

class DispenserDashboardPage extends StatefulWidget {
  const DispenserDashboardPage({super.key});

  @override
  State<DispenserDashboardPage> createState() => _DispenserDashboardPageState();
}

class _DispenserDashboardPageState extends State<DispenserDashboardPage> {
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
      context.read<RoleDashboardController>().loadDispenser();
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
        SnackBar(
          content: Text(
            CloudinaryUpload.lastErrorMessage ??
                'Image upload failed. Please try again.',
          ),
        ),
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

    final ok = await c.updateDispenserProfile(
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
        const SnackBar(
          content: Text('Dispenser profile updated successfully.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(c.error ?? 'Failed to update dispenser profile.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoleDashboardController>();
    final profile = c.dispenserProfile;
    _bindProfile(profile);

    return DashboardShell(
      child: c.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'Dispenser Dashboard',
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
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Medicine')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Current Qty')),
                    DataColumn(label: Text('Min Qty')),
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
                const SizedBox(height: 16),
                Text(
                  'Dispense History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                AppDataTable(
                  columns: const [
                    DataColumn(label: Text('Dispense ID')),
                    DataColumn(label: Text('Patient')),
                    DataColumn(label: Text('Prescription')),
                    DataColumn(label: Text('Date')),
                  ],
                  rows: c.dispenserHistory
                      .map(
                        (h) => DataRow(
                          cells: [
                            DataCell(Text(h.dispenseId.toString())),
                            DataCell(Text(h.patientName)),
                            DataCell(Text(h.prescriptionId.toString())),
                            DataCell(
                              Text(
                                DateFormat('dd MMM yyyy').format(h.dispensedAt),
                              ),
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
