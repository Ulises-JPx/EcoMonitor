import 'package:frontend/data/models/device.dart';
import 'package:frontend/data/services/api_service.dart';

/// DeviceRepository
/// ----------------
/// Abstraction layer for devices API.
class DeviceRepository {
  final ApiService apiService;

  DeviceRepository({required this.apiService});

  /// Fetch devices
  Future<List<Device>> getDevices() async {
    try {
      return await apiService.fetchDevices();
    } catch (e) {
      throw Exception("Error in DeviceRepository: $e");
    }
  }
}