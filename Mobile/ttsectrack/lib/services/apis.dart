class ApiConfig {
  static const String baseUrl = 'http://YOUR_FASTAPI_URL'; // Replace with your actual API URL

  static String get location => '$baseUrl/location';
  static String get locations => '$baseUrl/locations';
  static String locationsByUnit(String unitId) => '$baseUrl/locations/$unitId';
  static String get users => '$baseUrl/users';
  // Add more endpoints as needed
}
