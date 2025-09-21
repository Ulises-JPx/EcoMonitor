import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/state/device_provider.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Devices")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => context.read<DeviceProvider>().loadDevices(),
            child: const Text("Load Devices"),
          ),
          Expanded(
            child: _buildContent(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(DeviceProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(child: Text("Error: ${provider.error}"));
    }
    if (provider.devices.isNotEmpty) {
      return ListView.builder(
        itemCount: provider.devices.length,
        itemBuilder: (_, index) {
          final d = provider.devices[index];
          return ListTile(
            leading: const Icon(Icons.developer_board),
            title: Text(d.id),
          );
        },
      );
    }
    return const Center(child: Text("No devices loaded"));
  }
}