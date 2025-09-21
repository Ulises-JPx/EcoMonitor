import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/app_config.dart';
import 'package:frontend/data/models/sensor.dart';
import 'package:frontend/data/models/device.dart';
import 'package:frontend/data/models/sensor_data.dart';

/// ApiService
/// -----------
/// Handles HTTP requests to the backend API.
class ApiService {
  // Base URL is provided asynchronously by AppConfig.getApiBaseUrl()
  // so we resolve it inside each async method.

  /// Get list of sensors
  Future<List<Sensor>> fetchSensors() async {
    final baseUrl = await AppConfig.getApiBaseUrl();
    final response = await http.get(Uri.parse("$baseUrl${AppConfig.endpointSensors}"));

    if (response.statusCode == 200) {
      final raw = jsonDecode(response.body);
      if (raw == null || raw is! Map<String, dynamic>) {
        throw Exception("Unexpected sensors response format");
      }

      // Support both 'sensors' (english) and 'sensores' (spanish)
      final sensorsJson = (raw["sensors"] ?? raw["sensores"]);
      if (sensorsJson == null || sensorsJson is! Map<String, dynamic>) {
        throw Exception("No sensors object in response");
      }

      List<Sensor> sensors = [];
      sensorsJson.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          sensors.add(Sensor.fromJson(key, value));
        }
      });

      return sensors;
    } else {
      throw Exception("Failed to fetch sensors: ${response.statusCode}");
    }
  }

  /// Get list of devices
  Future<List<Device>> fetchDevices() async {
    final baseUrl = await AppConfig.getApiBaseUrl();
    final response = await http.get(Uri.parse("$baseUrl${AppConfig.endpointDevices}"));

    if (response.statusCode == 200) {
      final raw = jsonDecode(response.body);
      if (raw == null || raw is! Map<String, dynamic>) {
        throw Exception("Unexpected devices response format");
      }

      // Support both 'devices' and 'dispositivos'
      final devicesJson = raw["devices"] ?? raw["dispositivos"];
      if (devicesJson == null || devicesJson is! List) {
        throw Exception("No devices list in response");
      }

      return devicesJson.map((d) => Device.fromJson(d)).toList();
    } else {
      throw Exception("Failed to fetch devices: ${response.statusCode}");
    }
  }

  /// Get sensor data with optional filters
  Future<List<SensorData>> fetchSensorData({
    String? sensor,
    String? deviceId,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (sensor != null) queryParams["sensor"] = sensor;
    if (deviceId != null) queryParams["device_id"] = deviceId;
    if (startDate != null) queryParams["start_date"] = startDate;
    if (endDate != null) queryParams["end_date"] = endDate;

  final baseUrl = await AppConfig.getApiBaseUrl();
  final uri = Uri.parse("$baseUrl${AppConfig.endpointData}").replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final raw = jsonDecode(response.body);
      if (raw == null) {
        return [];
      }

      // Backend might return { data: [...], records: n } OR directly a list in some versions
      dynamic records;

      if (raw is Map<String, dynamic>) {
        records = (raw["data"] ?? raw["datos"] ?? raw["records"]);
      } else if (raw is List) {
        records = raw;
      }

      if (records == null) return [];

      if (records is! List) throw Exception("Unexpected data format from server");

      return (records as List).map((json) {
        if (json is Map<String, dynamic>) {
          return SensorData.fromJson(json);
        }
        // Skip non-object entries
        return null;
      }).whereType<SensorData>().toList();
    } else {
      throw Exception("Failed to fetch sensor data: ${response.statusCode}");
    }
  }
}