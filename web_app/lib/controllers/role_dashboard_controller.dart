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
  DoctorProfile? doctorProfile;
  List<PatientPrescriptionListItem> doctorPrescriptionList = [];

  // Admin
  AdminDashboardOverview? adminOverview;
  DashboardAnalytics? adminAnalytics;
  AdminProfileRespond? adminProfile;
  List<AuditEntry> adminAudits = [];
  List<UserListItem> adminUsers = [];
  List<InventoryItemInfo> adminInventory = [];

  // Lab
  LabToday? labSummary;
  List<LabTenHistory> labHistory = [];
  List<TestResult> labResults = [];
  List<LabTests> labAvailableTests = [];
  StaffProfileDto? labProfile;
  LabAnalyticsSnapshot? labAnalyticsSnapshot;
  bool isLabAnalyticsLoading = false;

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

  /// Loads only patient profile data.
  ///
  /// This is used by profile screens so they don't fail to render when
  /// unrelated patient endpoints (appointments, reports, etc.) fail.
  Future<void> loadPatientProfileOnly() => _load(() async {
    patientProfile = await _service.getPatientProfile();
  });

  /// Loads profile + clinical document summaries used in patient profile page.
  ///
  /// Keeps the profile page independent from unrelated endpoints while still
  /// showing doctor prescriptions and lab reports.
  Future<void> loadPatientProfileWithClinicalData() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      patientProfile = await _service.getPatientProfile();
    } catch (e) {
      error = e.toString();
    }

    try {
      final appointments = await _service.getPatientAppointments();
      patientAppointments = appointments
          .map(AppointmentModel.fromPrescription)
          .toList();
    } catch (e) {
      error ??= e.toString();
    }

    try {
      patientReports = await _service.getPatientReports();
    } catch (e) {
      error ??= e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

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
    doctorProfile = await _service.getDoctorProfile();
    doctorPrescriptionList = await _service.getDoctorPrescriptions();
  });

  Future<bool> updateDoctorProfile({
    required String name,
    required String email,
    required String phone,
    required String qualification,
    required String designation,
    String? profilePictureUrl,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final ok = await _service.updateDoctorProfile(
        name: name,
        email: email,
        phone: phone,
        qualification: qualification,
        designation: designation,
        profilePictureUrl: profilePictureUrl,
      );
      if (!ok) {
        error = 'Failed to update profile';
        return false;
      }
      doctorProfile = await _service.getDoctorProfile();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<PatientPrescriptionListItem>> searchDoctorPatients({
    required String query,
    int limit = 30,
  }) async {
    try {
      final rows = await _service.getDoctorPrescriptions(
        query: query,
        limit: limit,
      );
      doctorPrescriptionList = rows;
      notifyListeners();
      return rows;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return const [];
    }
  }

  Future<Map<String, String?>> lookupDoctorPatient(String query) async {
    try {
      return await _service.getDoctorPatientByPhoneOrName(query);
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return {'id': null, 'name': null};
    }
  }

  Future<int> saveDoctorPrescription({
    required Prescription prescription,
    required List<PrescribedItem> items,
    required String patientPhone,
  }) async {
    try {
      return await _service.createDoctorPrescription(
        prescription: prescription,
        items: items,
        patientPhone: patientPhone,
      );
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return -1;
    }
  }

  Future<void> loadAdmin() => _load(() async {
    adminOverview = await _service.getAdminOverview();
    adminAnalytics = await _service.getAdminAnalytics();
    adminProfile = await _service.getAdminProfile();
    adminAudits = await _service.getRecentAudit();
    adminUsers = await _service.getAdminUsers();
    adminInventory = await _service.getAdminInventory();
  });

  Future<bool> updateAdminProfile({
    required String name,
    required String phone,
    String? designation,
    String? qualification,
    String? profilePictureUrl,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await _service.updateAdminProfile(
        name: name,
        phone: phone,
        designation: designation,
        qualification: qualification,
        profilePictureUrl: profilePictureUrl,
      );
      final ok = res.trim().toUpperCase() == 'OK';
      if (!ok) {
        error = res;
        return false;
      }
      adminProfile = await _service.getAdminProfile();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLab() => _load(() async {
    labSummary = await _service.getLabSummary();
    labHistory = await _service.getLabHistory();
    labResults = await _service.getAllLabResults();
    labAvailableTests = await _service.getAllLabTests();
    labProfile = await _service.getLabStaffProfile();
  });

  Future<bool> updateLabStaffProfile({
    required String name,
    required String email,
    required String phone,
    required String qualification,
    required String designation,
    String? profilePictureUrl,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final ok = await _service.updateLabStaffProfile(
        name: name,
        email: email,
        phone: phone,
        qualification: qualification,
        designation: designation,
        profilePictureUrl: profilePictureUrl,
      );
      if (!ok) {
        error = 'Failed to update profile';
        return false;
      }
      labProfile = await _service.getLabStaffProfile();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changeMyPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final res = await _service.changeMyPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      final normalized = res.toLowerCase();
      if (normalized.contains('success')) {
        return true;
      }
      error = res;
      notifyListeners();
      return false;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadLabAnalyticsSnapshot({
    DateTime? fromDate,
    DateTime? toDateExclusive,
    String patientType = 'ALL',
  }) async {
    isLabAnalyticsLoading = true;
    error = null;
    notifyListeners();
    try {
      labAnalyticsSnapshot = await _service.getLabAnalyticsSnapshot(
        fromDate: fromDate,
        toDateExclusive: toDateExclusive,
        patientType: patientType,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLabAnalyticsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDispenser() => _load(() async {
    dispenserProfile = await _service.getDispenserProfile();
    dispenserStock = await _service.getDispenserStock();
    dispenserHistory = await _service.getDispenserHistory();
  });

  Future<bool> updateDispenserProfile({
    required String name,
    required String phone,
    required String qualification,
    required String designation,
    String? profilePictureUrl,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await _service.updateDispenserProfile(
        name: name,
        phone: phone,
        qualification: qualification,
        designation: designation,
        profilePictureUrl: profilePictureUrl,
      );
      final normalized = res.trim().toLowerCase();
      final ok = normalized == 'ok' || normalized.contains('success');
      if (!ok) {
        error = res;
        return false;
      }
      dispenserProfile = await _service.getDispenserProfile();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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
