// ============================================================
// API Configuration
// Backend internet server pe deploy hone ke baad, neeche wala
// URL apne actual server address se replace karein.
// Example: "https://clinic.hasanbabu.in/api"
// ============================================================
class ApiConfig {
  static const String baseUrl = "https://YOUR-SERVER-DOMAIN.com/api";

  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String patients = "$baseUrl/patients";
  static const String todayQueue = "$baseUrl/patients/today-queue";
}
