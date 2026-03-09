import 'package:backend_client/backend_client.dart';

class AppointmentModel {
  AppointmentModel({
    required this.id,
    required this.doctorName,
    required this.date,
    this.type,
  });

  final int id;
  final String doctorName;
  final DateTime date;
  final String? type;

  factory AppointmentModel.fromPrescription(PrescriptionList p) =>
      AppointmentModel(
        id: p.prescriptionId,
        doctorName: p.doctorName,
        date: p.date,
        type: p.sourceReportType,
      );
}
