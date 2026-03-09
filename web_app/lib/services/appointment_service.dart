import 'package:backend_client/backend_client.dart';

import 'api_service.dart';

class AppointmentService {
  final _client = ApiService.instance.client;

  Future<List<StaffInfo>> getDoctors() => _client.patient.getMedicalStaff();

  Future<List<PrescriptionList>> getAppointments() =>
      _client.patient.getMyPrescriptionList();

  Future<List<PatientReportDto>> getMedicalReports() =>
      _client.patient.getMyLabReports();
}
