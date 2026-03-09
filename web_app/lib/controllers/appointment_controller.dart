import 'package:backend_client/backend_client.dart';
import 'package:flutter/foundation.dart';

import '../models/appointment.dart';
import '../models/doctor.dart';
import '../services/appointment_service.dart';

class AppointmentController extends ChangeNotifier {
  AppointmentController(this._service);

  final AppointmentService _service;

  bool isLoading = false;
  String? error;

  List<DoctorModel> doctors = [];
  List<AppointmentModel> appointments = [];
  List<PatientReportDto> reports = [];

  Future<void> loadDashboardData() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final doctorRows = await _service.getDoctors();
      final appointmentRows = await _service.getAppointments();
      final reportRows = await _service.getMedicalReports();

      doctors = doctorRows.map(DoctorModel.fromStaffInfo).toList();
      appointments = appointmentRows
          .map(AppointmentModel.fromPrescription)
          .toList();
      reports = reportRows;
    } catch (_) {
      error = 'Failed to load data from backend.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
