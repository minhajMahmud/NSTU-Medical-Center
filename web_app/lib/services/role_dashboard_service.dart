import 'package:backend_client/backend_client.dart';

import 'api_service.dart';

class RoleDashboardService {
  final _client = ApiService.instance.client;

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

  // Lab
  Future<LabToday> getLabSummary() => _client.lab.getLabHomeTwoDaySummary();
  Future<List<LabTenHistory>> getLabHistory() =>
      _client.lab.getLast10TestHistory();
  Future<List<TestResult>> getAllLabResults() =>
      _client.lab.getAllTestResults();

  // Dispenser
  Future<DispenserProfileR?> getDispenserProfile() =>
      _client.dispenser.getDispenserProfile();
  Future<List<InventoryItemInfo>> getDispenserStock() =>
      _client.dispenser.listInventoryItems();
  Future<List<DispenseHistoryEntry>> getDispenserHistory() =>
      _client.dispenser.getDispenserDispenseHistory(limit: 30);
}
