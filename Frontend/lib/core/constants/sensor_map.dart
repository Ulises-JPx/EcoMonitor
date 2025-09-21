/// SensorMap
/// ----------
/// Maps human-friendly names to backend sensor keys.

class SensorMap {
  /// Map of display names (for UI) to backend sensor keys
  static const Map<String, String> displayToBackend = {
    "Temperature": "temperature",
    "Humidity": "humidity",
    "CO2": "co2",
    "Air Quality": "air_quality",
    "Light (Raw)": "light_raw",
    "Light (Voltage)": "light_voltage",
    "Light (%)": "light_percentage",
    "Light (State)": "light_state",
    "MQ135 (Raw)": "mq135_raw",
    "RS/R0 Ratio": "rs_r0",
  };

  /// Reverse map: backend → display
  static const Map<String, String> backendToDisplay = {
    "temperature": "Temperature",
    "humidity": "Humidity",
    "co2": "CO2",
    "air_quality": "Air Quality",
    "light_raw": "Light (Raw)",
    "light_voltage": "Light (Voltage)",
    "light_percentage": "Light (%)",
    "light_state": "Light (State)",
    "mq135_raw": "MQ135 (Raw)",
    "rs_r0": "RS/R0 Ratio",
  };
}