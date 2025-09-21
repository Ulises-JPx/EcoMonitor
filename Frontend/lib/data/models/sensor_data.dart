/// SensorData model
/// -----------------
/// Represents a single sensor measurement from /data endpoint.

class SensorData {
  final String timestamp;   // e.g. "2025-09-18T00:44:51-06:00"
  final String deviceId;    // e.g. "esp32-1"
  final String sensor;      // e.g. "temperature"
  final String type;        // "numeric" or "categorical"
  final String unit;        // e.g. "°C"
  final dynamic value;      // can be double, int, or String

  SensorData({
    required this.timestamp,
    required this.deviceId,
    required this.sensor,
    required this.type,
    required this.unit,
    required this.value,
  });

  /// Factory to build from backend JSON
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      timestamp: json["timestamp"] ?? "",
      deviceId: json["deviceId"] ?? "",
      sensor: json["sensor"] ?? "",
      type: json["type"] ?? "",
      unit: json["unit"] ?? "",
      value: json["value"], // keep dynamic
    );
  }

  /// Convert back to JSON
  Map<String, dynamic> toJson() {
    return {
      "timestamp": timestamp,
      "deviceId": deviceId,
      "sensor": sensor,
      "type": type,
      "unit": unit,
      "value": value,
    };
  }
}