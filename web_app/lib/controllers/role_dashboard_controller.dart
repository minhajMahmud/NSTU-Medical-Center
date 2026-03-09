import 'package:backend_client/backend_client.dart';
import 'package:flutter/foundation.dart';

import '../models/appointment.dart';
import '../models/doctor.dart';
import '../services/role_dashboard_service.dart';

class RoleDashboardController extends ChangeNotifier {
  RoleDashboardController(this._service);

  final RoleDashboardService _service;

  bool isLoading = false;
  String? error;

  // Patient
  // Patient
  PatientProfile? patientProfile;
  List<DoctorModel> patientDoctors = [];
  List<AppointmentModel> patientAppointments = [];
  List<PatientReportDto> patientReports = [];
  List<LabTests> patientLabTests = [];
  List<OndutyStaff> patientOnDutyStaff = [];
  List<AmbulanceContact> patientAmbulanceContacts = [];
  List<NotificationInfo> patientNotifications = [];

  // Doctor
  DoctorHomeData? doctorHome;
  List<PatientPrescriptionListItem> doctorPrescriptionList = [];

  // Admin
  AdminDashboardOverview? adminOverview;
  DashboardAnalytics? adminAnalytics;
  List<AuditEntry> adminAudits = [];
  List<UserListItem> adminUsers = [];
  List<InventoryItemInfo> adminInventory = [];

  // Lab
  LabToday? labSummary;
  List<LabTenHistory> labHistory = [];
  List<TestResult> labResults = [];

  // Dispenser
  DispenserProfileR? dispenserProfile;
  List<InventoryItemInfo> dispenserStock = [];
  List<DispenseHistoryEntry> dispenserHistory = [];

  Future<void> loadPatient() => _load(() async {
    final profile = await _service.getPatientProfile();
    final doctors = await _service.getPatientDoctors();
    final appointments = await _service.getPatientAppointments();
    final reports = await _service.getPatientReports();
    final labTests = await _service.getLabTests();
    final onDutyStaff = await _service.getOnDutyStaff();
    final ambulance = await _service.getAmbulanceContacts();
    final notifications = await _service.getPatientNotifications();

    patientProfile = profile;
    patientDoctors = doctors.map(DoctorModel.fromStaffInfo).toList();
    patientAppointments = appointments
        .map(AppointmentModel.fromPrescription)
        .toList();
    patientReports = reports;
    patientLabTests = labTests;
    patientOnDutyStaff = onDutyStaff;
    patientAmbulanceContacts = ambulance;
    patientNotifications = notifications;
  });

  Future<bool> updatePatientProfile({
    required String name,
    required String phone,
    String? bloodGroup,
    DateTime? dateOfBirth,
    String? gender,
    String? profileImageUrl,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _service.updatePatientProfile(
        name: name,
        phone: phone,
        bloodGroup: bloodGroup,
        dateOfBirth: dateOfBirth,
        gender: gender,
        profileImageUrl: profileImageUrl,
      );

      final normalized = result.trim().toLowerCase();
      if (normalized != 'profile updated successfully') {
        error = result;
        return false;
      }

      final profile = await _service.getPatientProfile();
      patientProfile = profile;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDoctor() => _load(() async {
    doctorHome = await _service.getDoctorHome();
    doctorPrescriptionList = await _service.getDoctorPrescriptions();
  });

  Future<void> loadAdmin() => _load(() async {
    adminOverview = await _service.getAdminOverview();
    adminAnalytics = await _service.getAdminAnalytics();
    adminAudits = await _service.getRecentAudit();
    adminUsers = await _service.getAdminUsers();
    adminInventory = await _service.getAdminInventory();
  });

  Future<void> loadLab() => _load(() async {
    labSummary = await _service.getLabSummary();
    labHistory = await _service.getLabHistory();
    labResults = await _service.getAllLabResults();
  });

  Future<void> loadDispenser() => _load(() async {
    dispenserProfile = await _service.getDispenserProfile();
    dispenserStock = await _service.getDispenserStock();
    dispenserHistory = await _service.getDispenserHistory();
  });

  Future<void> _load(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
