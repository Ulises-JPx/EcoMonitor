import 'package:flutter/material.dart';
import 'package:frontend/presentation/screens/login/login_screen.dart';
import 'package:frontend/presentation/screens/home/home_screen.dart';
import 'package:frontend/presentation/screens/sensors/sensors_screen.dart';
import 'package:frontend/presentation/screens/devices/devices_screen.dart';

/// AppRoutes
/// ----------
/// Centralizes all navigation routes in the app.
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String sensors = '/sensors';
  static const String devices = '/devices';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    sensors: (context) => const SensorsScreen(),
    devices: (context) => const DevicesScreen(),
  };
}