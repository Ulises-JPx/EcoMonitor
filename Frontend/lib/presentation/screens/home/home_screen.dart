import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/presentation/state/auth_provider.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/presentation/widgets/app_drawer.dart';
import 'package:frontend/core/utils/time_utils.dart';
import 'package:frontend/presentation/state/sensor_provider.dart';
import 'package:frontend/data/models/sensor_data.dart';
import 'package:frontend/core/constants/sensor_map.dart';
import 'package:frontend/presentation/screens/sensors/sensor_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Trigger first load after first frame. Timer will be started after
    // the initial batch load completes so we don't refresh mid-load.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // stop timer when leaving screen
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final provider = context.read<SensorProvider>();
    // Load all sensors in a single batch to avoid multiple UI refreshes
    // while initial data is being fetched. Use the provider's
    // refreshAllSensors which collects data for all sensors and
    // notifies listeners once when complete.
    await provider.refreshAllSensors();

    // Start periodic refresh only once initial load finished
    _timer ??= Timer.periodic(const Duration(seconds: 30), (timer) {
        provider.refreshAllSensors(); // periodic refresh, no awaiting here
      });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final sensorProvider = context.watch<SensorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                Text(
                "Welcome, ${authProvider.isLoggedIn ? "User" : "Guest"} 🌱",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "Here is a quick overview of your crop conditions:",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // If user hasn't selected widgets yet, show prominent CTA
              if (sensorProvider.selectedWidgets.isEmpty) ...[
                Card(
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Customize your dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                const Text('Add the cards you want to see on your home.'),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.add_box),
                                  label: const Text('Add widgets'),
                                  onPressed: () => _showAddWidgetsModal(sensorProvider),
                                )
                      ],
                    ),
                  ),
                ),
              ] else ...[
                _buildDashboardHeader(sensorProvider),
                const SizedBox(height: 12),
                _buildDashboard(sensorProvider),
              ],

              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.sensors),
                label: const Text(AppStrings.sensorsTitle),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.sensors);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.devices),
                label: const Text(AppStrings.devicesTitle),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.devices);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(SensorProvider provider) {
    if (provider.error != null) {
      return Center(child: Text("Error loading sensors: ${provider.error}"));
    }

  // latest values will be looked up per widget when building cards

    // If user has selected widgets, use that selection; otherwise default set
    final widgetsToShow = provider.selectedWidgets.isNotEmpty
        ? provider.selectedWidgets
        : ["temperature", "humidity", "co2", "light_state"];

    // Build full-width cards in a Column so each widget occupies the full width
    final cards = <Widget>[];
    for (final key in widgetsToShow) {
      final latest = _getLatestValue(provider.sensorData, key);
      final title = SensorMap.backendToDisplay[key] ?? key;
      cards.add(_buildStatCard(title, latest, key));
    }

    return Column(
      children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SizedBox(width: double.infinity, child: c))).toList(),
    );
  }

  SensorData? _getLatestValue(List<SensorData> allData, String sensor) {
    final filtered = allData.where((d) => d.sensor == sensor).toList();
    if (filtered.isEmpty) return null;
    return filtered.last;
  }

  Widget _buildStatCard(String title, SensorData? latest, String backendKey) {
    final value = latest?.value;
    final unit = latest?.unit;
    final display = value != null ? "$value ${unit ?? ''}" : "--";
    final timestamp = latest?.timestamp;
    return GestureDetector(
      onTap: () async {
        // Navigate to detail view for this sensor
        final provider = context.read<SensorProvider>();
        await provider.loadSensorData(sensor: backendKey);
        final data = provider.sensorData.where((d) => d.sensor == backendKey).toList();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SensorDetailScreen(backendKey: backendKey, displayName: title, data: data)),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.sensors, size: 26, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(display, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    if (timestamp != null)
                      Text(friendlyTimestamp(timestamp), style: const TextStyle(fontSize: 10, color: Colors.black45), maxLines: 1, overflow: TextOverflow.ellipsis),
                    // If provider is loading we keep the card visible and show a very small loader
                    if (context.watch<SensorProvider>().isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
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
      return ts; // fallback to raw
    }
  }

  /// Header showing last update time and button to add widgets
  Widget _buildDashboardHeader(SensorProvider provider) {
    final last = provider.lastUpdated;
    String subtitle;
    if (last == null) {
      subtitle = "Never updated";
    } else {
      final diff = DateTime.now().difference(last);
      if (diff.inSeconds < 60) {
        subtitle = "Updated ${diff.inSeconds}s ago";
      } else if (diff.inMinutes < 60) {
        subtitle = "Updated ${diff.inMinutes}m ago";
      } else if (diff.inHours < 24) {
        subtitle = "Updated ${diff.inHours}h ago";
      } else {
        subtitle = "Updated ${diff.inDays}d ago";
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(subtitle, style: const TextStyle(color: Colors.black54)),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_box),
          label: const Text('Agregar widgets'),
          onPressed: () => _showAddWidgetsModal(provider),
        ),
      ],
    );
  }

  void _showAddWidgetsModal(SensorProvider provider) {
    final entries = SensorMap.displayToBackend.entries.toList();
    final Set<String> selected = Set<String>.from(provider.selectedWidgets);

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select widgets to display', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final display = entries[index].key;
                      final backend = entries[index].value;
                      final isSel = selected.contains(backend);
                      return CheckboxListTile(
                        title: Text(display),
                        value: isSel,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) selected.add(backend); else selected.remove(backend);
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        provider.setSelectedWidgets(selected.toList());
                        Navigator.pop(ctx);
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                )
              ],
            ),
          );
        });
      },
    );
  }
}