import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:backend_client/backend_client.dart';

import '../../controllers/role_dashboard_controller.dart';
import '../../widgets/common/dashboard_shell.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  DateTime? _editDob;
  String _editBloodGroup = '';
  String _editGender = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RoleDashboardController>().loadPatient();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _bindProfile(PatientProfile profile) {
    if (_isEditing) return;
    _nameController.text = profile.name;
    _phoneController.text = profile.phone;
    _editBloodGroup = profile.bloodGroup ?? '';
    _editGender = profile.gender ?? '';
    _editDob = profile.dateOfBirth;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _editDob ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _editDob = picked);
    }
  }

  Future<void> _saveChanges(RoleDashboardController c) async {
    final ok = await c.updatePatientProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      bloodGroup: _editBloodGroup.isEmpty ? null : _editBloodGroup,
      dateOfBirth: _editDob,
      gender: _editGender.isEmpty ? null : _editGender,
      profileImageUrl: null,
    );

    if (!mounted) return;

    if (ok) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(c.error ?? 'Failed to update profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RoleDashboardController>();
    final profile = c.patientProfile;
    final theme = Theme.of(context);

    if (profile != null) {
      _bindProfile(profile);
    }

    return DashboardShell(
      child: c.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (profile != null) ...[
                  _ProfileHeaderCard(
                    profile: profile,
                    isEditing: _isEditing,
                    onEditPressed: () => setState(() => _isEditing = true),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Personal Information',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Last updated: 2 days ago',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isEditing)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Full Name',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    enabled: false,
                                    controller: TextEditingController(
                                      text: profile.email,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Email Address (readonly)',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone Number',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _editBloodGroup.isEmpty
                                        ? null
                                        : _editBloodGroup,
                                    decoration: const InputDecoration(
                                      labelText: 'Blood Group',
                                    ),
                                    items:
                                        const [
                                              'A+',
                                              'A-',
                                              'B+',
                                              'B-',
                                              'AB+',
                                              'AB-',
                                              'O+',
                                              'O-',
                                            ]
                                            .map(
                                              (g) => DropdownMenuItem(
                                                value: g,
                                                child: Text(g),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (v) => setState(
                                      () => _editBloodGroup = v ?? '',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _editGender.isEmpty
                                        ? null
                                        : _editGender,
                                    decoration: const InputDecoration(
                                      labelText: 'Gender',
                                    ),
                                    items: const ['Male', 'Female', 'Other']
                                        .map(
                                          (g) => DropdownMenuItem(
                                            value: g,
                                            child: Text(g),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _editGender = v ?? ''),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickDob,
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Date of Birth',
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                      child: Text(
                                        _editDob == null
                                            ? 'Not Set'
                                            : DateFormat(
                                                'd MMMM yyyy',
                                              ).format(_editDob!.toLocal()),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _InfoTile(
                          icon: Icons.badge_outlined,
                          title: 'FULL NAME',
                          value: profile.name,
                        ),
                        _InfoTile(
                          icon: Icons.email_outlined,
                          title: 'EMAIL ADDRESS',
                          value: profile.email,
                        ),
                        _InfoTile(
                          icon: Icons.phone_outlined,
                          title: 'PHONE NUMBER',
                          value: profile.phone,
                        ),
                        _InfoTile(
                          icon: Icons.bloodtype_outlined,
                          title: 'BLOOD GROUP',
                          value: (profile.bloodGroup?.isNotEmpty ?? false)
                              ? profile.bloodGroup!
                              : 'Not Set',
                        ),
                        _InfoTile(
                          icon: Icons.person_outline,
                          title: 'GENDER',
                          value: (profile.gender?.isNotEmpty ?? false)
                              ? profile.gender!
                              : 'Not Set',
                        ),
                        _InfoTile(
                          icon: Icons.cake_outlined,
                          title: 'DATE OF BIRTH',
                          value: profile.dateOfBirth == null
                              ? 'Not Set'
                              : DateFormat(
                                  'd MMMM yyyy',
                                ).format(profile.dateOfBirth!.toLocal()),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Account & Security',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE8F1FF),
                            child: Icon(Icons.lock_outline),
                          ),
                          title: const Text(
                            'Change Password',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: const Text(
                            'Ensure your account is using a strong password',
                          ),
                          trailing: FilledButton.tonal(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Use Forgot Password from login page for now.',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Update Password'),
                          ),
                        ),
                        const Divider(height: 1),
                        const ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(0xFFFFF1E8),
                            child: Icon(Icons.verified_user_outlined),
                          ),
                          title: Text(
                            'Two-Factor Authentication',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            'Add an extra layer of security to your account',
                          ),
                          trailing: Switch(value: false, onChanged: null),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Some personal details can only be changed by visiting the medical center help desk for verification.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          if (_isEditing) {
                            setState(() => _isEditing = false);
                            _bindProfile(profile);
                          } else {
                            c.loadPatient();
                          }
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: c.isLoading
                            ? null
                            : _isEditing
                            ? () => _saveChanges(c)
                            : () => setState(() => _isEditing = true),
                        child: Text(
                          _isEditing ? 'Save Changes' : 'Edit Profile',
                        ),
                      ),
                    ],
                  ),
                ] else
                  const Text('Could not load profile information.'),
              ],
            ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.profile,
    required this.isEditing,
    required this.onEditPressed,
  });

  final dynamic profile;
  final bool isEditing;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: const Color(0xFFEAF2FD),
                  child: Text(
                    profile.name.isNotEmpty
                        ? profile.name
                              .trim()
                              .split(' ')
                              .take(2)
                              .map((e) => e[0])
                              .join()
                              .toUpperCase()
                        : 'P',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        profile.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6FAEF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Active Patient',
                          style: TextStyle(
                            color: Color(0xFF1C8B4B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _pill(Icons.bloodtype, profile.bloodGroup ?? 'Not Set'),
                      _pill(Icons.phone, profile.phone),
                      _pill(Icons.location_on_outlined, 'Patient'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: isEditing ? null : onEditPressed,
              child: Text(isEditing ? 'Editing...' : 'Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Text(value),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 420),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: const Color(0xFF8A9AB2)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      letterSpacing: .6,
                      color: Color(0xFF8A9AB2),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
