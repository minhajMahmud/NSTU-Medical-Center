import 'package:backend_client/backend_client.dart';
import 'dart:convert';

import 'api_service.dart';

class RoleDashboardService {
  final _client = ApiService.instance.client;
  final _keyManager = ApiService.instance.authKeyManager;

  String? _currentEmailFromToken(String? token) {
    if (token == null || token.isEmpty) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(payload);
      if (map is Map<String, dynamic>) {
        final sub = map['sub'];
        return sub?.toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getCurrentEmail() async {
    final token = await _keyManager.get();
    return _currentEmailFromToken(token);
  }

  // Patient
  Future<PatientProfile?> getPatientProfile() =>
      _client.patient.getPatientProfile();
  Future<List<StaffInfo>> getPatientDoctors() =>
      _client.patient.getMedicalStaff();
  Future<List<PrescriptionList>> getPatientAppointments() =>
      _client.patient.getMyPrescriptionList();
  Future<List<PatientReportDto>> getPatientReports() =>
      _client.patient.getMyLabReports();
  Future<List<LabTests>> getLabTests() => _client.patient.listTests();
  Future<List<OndutyStaff>> getOnDutyStaff() =>
      _client.patient.getOndutyStaff();
  Future<List<AmbulanceContact>> getAmbulanceContacts() =>
      _client.patient.getAmbulanceContacts();
  Future<List<NotificationInfo>> getPatientNotifications() =>
      _client.notification.getMyNotifications(limit: 50);

  Future<String> updatePatientProfile({
    required String name,
    required String phone,
    String? bloodGroup,
    DateTime? dateOfBirth,
    String? gender,
    String? profileImageUrl,
  }) => _client.patient.updatePatientProfile(
    name,
    phone,
    bloodGroup,
    dateOfBirth,
    gender,
    profileImageUrl,
  );

  // Doctor
  Future<DoctorHomeData> getDoctorHome() => _client.doctor.getDoctorHomeData();
  Future<DoctorProfile?> getDoctorProfile() =>
      _client.doctor.getDoctorProfile(0);
  Future<bool> updateDoctorProfile({
    required String name,
    required String email,
    required String phone,
    required String qualification,
    required String designation,
    String? profilePictureUrl,
  }) => _client.doctor.updateDoctorProfile(
    0,
    name,
    email,
    phone,
    profilePictureUrl,
    designation,
    qualification,
    null,
  );
  Future<List<PatientPrescriptionListItem>> getDoctorPrescriptions({
    String? query,
    int limit = 30,
  }) => _client.doctor.getPatientPrescriptionList(
    query: query,
    limit: limit,
    offset: 0,
  );

  // Admin
  Future<AdminDashboardOverview> getAdminOverview() =>
      _client.adminReportEndpoints.getAdminDashboardOverview();
  Future<DashboardAnalytics> getAdminAnalytics() =>
      _client.adminReportEndpoints.getDashboardAnalytics();
  Future<List<AuditEntry>> getRecentAudit() =>
      _client.adminEndpoints.getRecentAuditLogs(24, 30);
  Future<List<UserListItem>> getAdminUsers({
    String role = 'ALL',
    int limit = 100,
  }) => _client.adminEndpoints.listUsersByRole(role, limit);
  Future<List<InventoryItemInfo>> getAdminInventory() =>
      _client.adminInventoryEndpoints.listInventoryItems();
  Future<AdminProfileRespond?> getAdminProfile() async {
    final email = await _getCurrentEmail();
    if (email == null || email.isEmpty) return null;
    return _client.adminEndpoints.getAdminProfile(email);
  }

  Future<String> updateAdminProfile({
    required String name,
    required String phone,
    String? designation,
    String? qualification,
    String? profilePictureUrl,
  }) async {
    final email = await _getCurrentEmail();
    if (email == null || email.isEmpty)
      return 'Unable to resolve current user email';
    return _client.adminEndpoints.updateAdminProfile(
      email,
      name,
      phone,
      profilePictureUrl,
      designation,
      qualification,
    );
  }

  // Lab
  Future<LabToday> getLabSummary() => _client.lab.getLabHomeTwoDaySummary();
  Future<List<LabTenHistory>> getLabHistory() =>
      _client.lab.getLast10TestHistory();
  Future<List<TestResult>> getAllLabResults() =>
      _client.lab.getAllTestResults();
  Future<List<LabTests>> getAllLabTests() => _client.lab.getAllLabTests();
  Future<LabAnalyticsSnapshot> getLabAnalyticsSnapshot({
    DateTime? fromDate,
    DateTime? toDateExclusive,
    String patientType = 'ALL',
  }) => _client.lab.getAnalyticsSnapshot(
    fromDate: fromDate,
    toDateExclusive: toDateExclusive,
    patientType: patientType,
  );
  Future<StaffProfileDto?> getLabStaffProfile() =>
      _client.lab.getStaffProfile();
  Future<bool> updateLabStaffProfile({
    required String name,
    required String email,
    required String phone,
    required String qualification,
    required String designation,
    String? profilePictureUrl,
  }) => _client.lab.updateStaffProfile(
    name: name,
    phone: phone,
    email: email,
    designation: designation,
    qualification: qualification,
    profilePictureUrl: profilePictureUrl,
  );
  Future<String> changeMyPassword({
    required String currentPassword,
    required String newPassword,
  }) => _client.password.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );

  // Dispenser
  Future<DispenserProfileR?> getDispenserProfile() =>
      _client.dispenser.getDispenserProfile();
  Future<String> updateDispenserProfile({
    required String name,
    required String phone,
    required String qualification,
    required String designation,
    String? profilePictureUrl,
  }) => _client.dispenser.updateDispenserProfile(
    name: name,
    phone: phone,
    qualification: qualification,
    designation: designation,
    profilePictureUrl: profilePictureUrl,
  );
  Future<List<InventoryItemInfo>> getDispenserStock() =>
      _client.dispenser.listInventoryItems();
  Future<List<DispenseHistoryEntry>> getDispenserHistory() =>
      _client.dispenser.getDispenserDispenseHistory(limit: 30);
}
