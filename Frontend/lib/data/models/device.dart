/// Device model
/// -------------
/// Represents an IoT device that sends sensor data.

class Device {
  final String id; // e.g. "esp32-1"

  Device({required this.id});

  /// Factory to create from JSON
  factory Device.fromJson(dynamic json) {
    // Backend returns devices as a list of strings
    if (json is String) {
      return Device(id: json);
    }
    // If backend later returns objects, handle that
    if (json is Map<String, dynamic>) {
      return Device(id: json['id'] ?? '');
    }
    return Device(id: '');
  }

  /// Convert back to JSON
  Map<String, dynamic> toJson() {
    return {"id": id};
  }
}