import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'core/theme/app_theme.dart';

// Routes
import 'routes/app_routes.dart';

// State (providers)
import 'presentation/state/auth_provider.dart';
import 'presentation/state/sensor_provider.dart';
import 'presentation/state/device_provider.dart';

void main() {
  runApp(const EcoMonitorApp());
}

class EcoMonitorApp extends StatelessWidget {
  const EcoMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SensorProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
      ],
      child: MaterialApp(
        title: 'Eco Monitor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login, // Start at Login
        routes: AppRoutes.routes,
      ),
    );
  }
}