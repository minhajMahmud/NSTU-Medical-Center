enum AppRole { patient, doctor, admin, lab, dispenser, unknown }

class RoleUtils {
  static AppRole parse(String? role) {
    final v = role?.trim().toUpperCase();
    switch (v) {
      case 'STUDENT':
      case 'TEACHER':
      case 'STAFF':
      case 'OUTSIDE':
      case 'PATIENT':
        return AppRole.patient;
      case 'DOCTOR':
        return AppRole.doctor;
      case 'ADMIN':
        return AppRole.admin;
      case 'LAB':
      case 'LABSTAFF':
      case 'LAB_TESTER':
        return AppRole.lab;
      case 'DISPENSER':
        return AppRole.dispenser;
      default:
        return AppRole.unknown;
    }
  }

  static String dashboardPathForRole(AppRole role) {
    switch (role) {
      case AppRole.patient:
        return '/patient/dashboard';
      case AppRole.doctor:
        return '/doctor/dashboard';
      case AppRole.admin:
        return '/admin/dashboard';
      case AppRole.lab:
        return '/lab/dashboard';
      case AppRole.dispenser:
        return '/dispenser/dashboard';
      case AppRole.unknown:
        return '/home';
    }
  }
}
