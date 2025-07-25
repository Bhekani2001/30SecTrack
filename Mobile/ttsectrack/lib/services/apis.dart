class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000/';

  static String get location => '$baseUrl/location';
  static String get locations => '$baseUrl/locations';
  static String locationsByUnit(String unitId) => '$baseUrl/locations/$unitId';
  static String get users => '$baseUrl/users';

}
