import 'dart:io' show Platform, NetworkInterface;
import 'package:flutter/foundation.dart' show kIsWeb;

/// AppConfig
/// ----------
/// Global configuration values with platform-aware base URL.
class AppConfig {
  static String? _cachedIp;

  /// Get the base API URL depending on platform
  static Future<String> getApiBaseUrl() async {
    if (kIsWeb) {
      // Web can't use dart:io, fallback to manual LAN IP
      return "http://127.0.0.1:5001"; // replace with your LAN IP
    } else if (Platform.isAndroid || Platform.isIOS) {
      // 📱 Mobile apps need LAN IP (auto-detect if possible)
      final ip = await _getLocalIp();
      return "http://$ip:5001";
    } else {
      // 💻 Desktop can use localhost
      return "http://localhost:5001";
    }
  }

  // Endpoints
  static const String endpointData = "/data";
  static const String endpointSensors = "/sensors";
  static const String endpointDevices = "/devices";

  /// Auto-detect LAN IP (first non-loopback IPv4)
  static Future<String> _getLocalIp() async {
    if (_cachedIp != null) return _cachedIp!;

    try {
      final interfaces = await NetworkInterface.list();
      for (var iface in interfaces) {
        for (var addr in iface.addresses) {
          if (!addr.isLoopback && addr.type.name == "IPv4") {
            _cachedIp = addr.address;
            return _cachedIp!;
          }
        }
      }
    } catch (e) {
      print("⚠️ Failed to auto-detect IP, using localhost: $e");
    }

    _cachedIp = "127.0.0.1";
    return _cachedIp!;
  }
}