import 'package:dio/dio.dart';
import '../models/location_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<bool> sendLocation({
    required String unitId,
    required LocationModel location,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/location',
        data: {
          'unit_id': unitId,
          'latitude': location.latitude,
          'longitude': location.longitude,
          'accuracy': location.accuracy,
          'timestamp': location.timestamp.toIso8601String(),
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // Optionally log error
      return false;
    }
  }

  Future<List<LocationModel>> getLocationHistory({String? unitId}) async {
    try {
      final url = unitId != null
          ? '$baseUrl/locations/$unitId'
          : '$baseUrl/locations';
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => LocationModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      // Optionally log error
      return [];
    }
  }
}
