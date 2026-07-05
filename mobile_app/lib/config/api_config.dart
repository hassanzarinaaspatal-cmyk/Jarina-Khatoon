// ============================================================
// API Configuration
// ============================================================
class ApiConfig {
  static const String baseUrl = "https://jarina-khatoon-production.up.railway.app/api";

  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String patients = "$baseUrl/patients";
  static const String todayQueue = "$baseUrl/patients/today-queue";
}