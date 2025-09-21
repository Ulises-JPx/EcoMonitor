/// Sensor model
/// -------------
/// Represents a single sensor definition (metadata).

class Sensor {
  final String name;        // e.g. "temperature"
  final String column;      // e.g. "tempC"
  final String unit;        // e.g. "°C"
  final String description; // e.g. "Temperature in Celsius"
  final String type;        // "numeric" or "categorical"

  Sensor({
    required this.name,
    required this.column,
    required this.unit,
    required this.description,
    required this.type,
  });

  /// Factory to create a Sensor from JSON (backend response)
  factory Sensor.fromJson(String name, Map<String, dynamic> json) {
    return Sensor(
      name: name,
      column: json['column'] ?? '',
      unit: json['unit'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
    );
  }

  /// Convert Sensor back to JSON
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "column": column,
      "unit": unit,
      "description": description,
      "type": type,
    };
  }
}