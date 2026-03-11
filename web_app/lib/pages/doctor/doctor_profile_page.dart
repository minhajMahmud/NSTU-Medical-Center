import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../utils/cloudinary_upload.dart';
import '../../widgets/common/change_password_dialog.dart';
import '../../widgets/common/dashboard_shell.dart';
import '../../widgets/common/role_profile_form_card.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
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
    final ok = await c.updateDoctorProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      qualification: _qualificationCtrl.text.trim(),
      designation: _designationCtrl.text.trim(),
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
    _bindProfile(profile);

    return DashboardShell(
      child: c.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'Doctor • Profile',
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
}
