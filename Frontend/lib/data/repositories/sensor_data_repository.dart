import 'package:frontend/data/models/sensor_data.dart';
import 'package:frontend/data/services/api_service.dart';

/// SensorDataRepository
/// ---------------------
/// Provides an abstraction for fetching sensor measurements.
class SensorDataRepository {
  final ApiService _apiService = ApiService();

  Future<List<SensorData>> getSensorData({
    String? sensor,
    String? deviceId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _apiService.fetchSensorData(
        sensor: sensor,
        deviceId: deviceId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception("Error in SensorDataRepository: $e");
    }
  }
}