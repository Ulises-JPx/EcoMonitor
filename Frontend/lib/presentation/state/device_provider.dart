import 'package:flutter/material.dart';
import 'package:frontend/data/models/device.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/data/repositories/device_repository.dart';

/// DeviceProvider
/// ---------------
/// Manages devices state.
class DeviceProvider with ChangeNotifier {
  final DeviceRepository _repository = DeviceRepository(apiService: ApiService());

  List<Device> _devices = [];
  bool _isLoading = false;
  String? _error;

  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load available devices
  Future<void> loadDevices() async {
    _setLoading(true);
    try {
      _devices = await _repository.getDevices();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}