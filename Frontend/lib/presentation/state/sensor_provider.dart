import 'package:flutter/foundation.dart';
import 'package:frontend/data/models/sensor_data.dart';
import 'package:frontend/data/models/sensor.dart';
import 'package:frontend/data/models/device.dart';
import 'package:frontend/data/repositories/sensor_repository.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/core/constants/sensor_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SensorProvider
/// ---------------
/// State management for sensors and their data.
class SensorProvider extends ChangeNotifier {
  final SensorRepository _repository = SensorRepository(apiService: ApiService());

  bool isLoading = false;
  String? error;
  List<Sensor> sensors = [];
  List<Device> devices = [];
  List<SensorData> sensorData = [];
  /// User-selected widgets to show on dashboard (backend keys)
  List<String> selectedWidgets = [];

  /// Timestamp of the last successful refresh
  DateTime? lastUpdated;

  SensorProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getStringList('selectedWidgets') ?? [];
      selectedWidgets = keys;
      notifyListeners();
    } catch (e) {
      debugPrint('Could not load preferences: $e');
    }
  }

  /// Load available sensors
  Future<void> loadSensors() async {
    _setLoading(true);
    try {
      sensors = await _repository.getSensors();
      error = null;
    } catch (e) {
      error = "Error loading sensors: $e";
    }
    _setLoading(false);
  }

  /// Load devices
  Future<void> loadDevices() async {
    _setLoading(true);
    try {
      devices = await _repository.getDevices();
      error = null;
    } catch (e) {
      error = "Error loading devices: $e";
    }
    _setLoading(false);
  }

  /// Load data for a specific sensor
  Future<void> loadSensorData({required String sensor}) async {
    // Preserve old values while fetching. If new data arrives, replace only that sensor's entries.
    _setLoading(true);
    try {
      final data = await _repository.getSensorData(sensor: sensor);
      if (data.isNotEmpty) {
        // remove old entries for this sensor and add new ones
        sensorData.removeWhere((d) => d.sensor == sensor);
        sensorData.addAll(data);
      } else {
        // if empty result, keep existing values unchanged
        debugPrint('No data returned for $sensor; keeping existing values');
      }
      error = null;
    } catch (e) {
      // on error keep existing values and report error
      debugPrint('Error loading sensor data for $sensor: $e');
      error = "Error loading sensor data: $e";
    }
    _setLoading(false);
  }

  /// Helper to ensure we have at least one (latest) value for a sensor (used before navigating)
  Future<void> ensureLatestForSensor(String sensor) async {
    // If we already have a latest value, don't fetch immediately
    if (sensorData.any((d) => d.sensor == sensor)) return;
    await loadSensorData(sensor: sensor);
  }

  /// Refresh all sensors with their latest data
  Future<void> refreshAllSensors() async {
    // Keep current data visible while fetching new values
    _setLoading(true);
    try {
      final Map<String, String> sensorMap = SensorMap.displayToBackend;

      // Build current map by sensor for easy replacement
      final Map<String, SensorData> currentBySensor = {
        for (final d in sensorData) d.sensor: d
      };

      // Collect new values into a map without mutating UI state yet
      final Map<String, SensorData> newBySensor = {};

      for (final backendKey in sensorMap.values) {
        try {
          final data = await _repository.getSensorData(sensor: backendKey);
          if (data.isNotEmpty) {
            newBySensor[backendKey] = data.first; // latest value per sensor
          }
        } catch (e) {
          // skip individual sensor error, keep existing value if any
          debugPrint("⚠️ Error refreshing $backendKey: $e");
        }
      }

      // Merge: start from current values, overwrite with any new ones
      final merged = Map<String, SensorData>.from(currentBySensor);
      for (final entry in newBySensor.entries) {
        merged[entry.key] = entry.value;
      }

      // Replace sensorData once with merged list to trigger a single UI update
      sensorData = merged.values.toList();
  // record last update time
  lastUpdated = DateTime.now();
      error = null;
    } catch (e) {
      error = "Error refreshing sensors: $e";
    }
    _setLoading(false);
  }

  /// Toggle widget selection (adds if missing, removes if present)
  void toggleWidget(String backendKey) {
    if (selectedWidgets.contains(backendKey)) {
      selectedWidgets.remove(backendKey);
    } else {
      selectedWidgets.add(backendKey);
    }
    _saveSelectedWidgets();
    notifyListeners();
  }

  /// Replace the selected widgets list
  void setSelectedWidgets(List<String> keys) {
    selectedWidgets = List.from(keys);
    _saveSelectedWidgets();
    notifyListeners();
  }

  /// Clear selection
  void clearSelectedWidgets() {
    selectedWidgets = [];
    _saveSelectedWidgets();
    notifyListeners();
  }

  Future<void> _saveSelectedWidgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('selectedWidgets', selectedWidgets);
    } catch (e) {
      debugPrint('Could not save preferences: $e');
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}