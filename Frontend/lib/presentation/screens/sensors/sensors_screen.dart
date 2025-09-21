import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/state/sensor_provider.dart';
import 'package:frontend/data/models/sensor_data.dart';
import 'package:frontend/core/constants/sensor_map.dart';
import 'package:frontend/core/utils/time_utils.dart';
import 'package:frontend/presentation/widgets/app_drawer.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/presentation/screens/sensors/sensor_detail_screen.dart';

/// SensorsScreen
/// --------------
/// Dashboard to view sensors and their latest data, with auto-refresh.
class SensorsScreen extends StatefulWidget {
  const SensorsScreen({super.key});

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Load sensors initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SensorProvider>().loadSensors();
    });

    // Auto-refresh every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      context.read<SensorProvider>().refreshAllSensors();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("🌱 Sensors Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<SensorProvider>().refreshAllSensors();
        },
        child: _buildContent(provider, context),
      ),
    );
  }

  Widget _buildContent(SensorProvider provider, BuildContext context) {
    if (provider.error != null) {
      return Center(
        child: Text("⚠️ Error: ${provider.error}"),
      );
    }
    final sensors = SensorMap.displayToBackend.keys.toList();

    // Show a short legend above the grid so users know they can tap cards
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text('Tap a card for more information', style: TextStyle(fontSize: 14, color: Colors.black54)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: sensors.length,
          itemBuilder: (context, index) {
        final displayName = sensors[index];
        final backendKey = SensorMap.displayToBackend[displayName];

        // Get latest data for this sensor (nullable-safe)
        SensorData? latest;
        if (backendKey != null && provider.sensorData.isNotEmpty) {
          for (final d in provider.sensorData) {
            if (d.sensor == backendKey) {
              latest = d;
              break;
            }
          }
        }

                return GestureDetector(
          onTap: () async {
            if (backendKey == null) return;
            // Load detailed data first, then navigate to detail page
            await context.read<SensorProvider>().loadSensorData(sensor: backendKey);
            final data = context.read<SensorProvider>().sensorData.where((d) => d.sensor == backendKey).toList();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SensorDetailScreen(backendKey: backendKey, displayName: displayName, data: data)),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sensors,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                    latest != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${latest.value} ${latest.unit}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              friendlyTimestamp(latest.timestamp),
                              style: const TextStyle(fontSize: 11, color: Colors.black38),
                            ),
                          ],
                        )
                      : const Text(
                          "Loading...",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
          },
        ),
      ],
    );
  }

  String _formatTimestamp(String ts) {
    try {
      final dt = DateTime.parse(ts).toLocal();
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$y-$m-$d $hh:$mm';
    } catch (_) {
      return ts;
    }
  }
}