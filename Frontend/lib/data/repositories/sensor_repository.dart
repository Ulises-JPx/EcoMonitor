import 'package:frontend/data/models/sensor.dart';
import 'package:frontend/data/models/sensor_data.dart';
import 'package:frontend/data/models/device.dart';
import 'package:frontend/data/services/api_service.dart';

/// SensorRepository
/// ----------------
/// Abstraction layer between UI/state and ApiService.
class SensorRepository {
  final ApiService apiService;

  SensorRepository({required this.apiService});

  /// Fetch all sensors metadata
  Future<List<Sensor>> getSensors() async {
    return await apiService.fetchSensors();
  }

  /// Fetch devices
  Future<List<Device>> getDevices() async {
    return await apiService.fetchDevices();
  }

  /// Fetch sensor data with optional filters
  Future<List<SensorData>> getSensorData({
    String? sensor,
    String? deviceId,
    String? startDate,
    String? endDate,
  }) async {
    return await apiService.fetchSensorData(
      sensor: sensor,
      deviceId: deviceId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}