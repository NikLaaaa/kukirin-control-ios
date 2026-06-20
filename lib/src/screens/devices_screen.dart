import 'package:flutter/material.dart';

import '../controllers/scooter_app_controller.dart';
import '../models/protocol_profile.dart';
import '../models/scooter_device.dart';
import '../theme/app_theme.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key, required this.controller});

  final ScooterAppController controller;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                'Search Devices',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.isPreviewOnlyPlatform
                    ? 'This desktop build is for GUI preview. Real BLE scanning is intentionally disabled on Windows and stays in the iPhone build.'
                    : 'Scan nearby BLE devices, connect to a scooter, and inspect what the dashboard exposes before we bind real commands.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppPalette.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _StatusCard(controller: controller),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.isScanning
                          ? controller.stopScan
                          : controller.startScan,
                      icon: Icon(
                        controller.isScanning
                            ? Icons.pause_circle
                            : Icons.radar,
                      ),
                      label: Text(controller.isScanning ? 'Stop' : 'Search'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.startDemoMode,
                      icon: const Icon(Icons.smart_toy_outlined),
                      label: const Text('Demo'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Bluetooth Devices',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              if (controller.devices.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      controller.isScanning
                          ? 'Scanning is active. Keep your scooter dashboard awake and stay within Bluetooth range.'
                          : 'No devices collected yet. Start a scan to look for KuKirin or generic BLE peripherals.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ),
                ),
              for (final device in controller.devices) ...[
                _DeviceCard(
                  device: device,
                  isConnected: controller.connectedDevice?.id == device.id,
                  onConnect: () => controller.connectToDevice(device),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 20),
              Text(
                'Prepared Model Families',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              for (final profile in controller.availableProfiles) ...[
                _ProfileCard(profile: profile),
                const SizedBox(height: 12),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.controller});

  final ScooterAppController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bluetooth Status',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(label: Text('Adapter: ${controller.bleStatusLabel()}')),
                Chip(label: Text('Session: ${controller.connectionLabel()}')),
                if (controller.connectedDevice != null)
                  Chip(label: Text(controller.connectedDevice!.displayName)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              controller.statusMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
            ),
            if (controller.lastError != null) ...[
              const SizedBox(height: 10),
              Text(
                controller.lastError!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppPalette.accentDanger),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.device,
    required this.isConnected,
    required this.onConnect,
  });

  final ScooterDevice device;
  final bool isConnected;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.displayName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        device.looksLikeKukirin
                            ? 'Looks like a KuKirin-family device'
                            : 'Generic BLE peripheral',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPalette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(label: Text('RSSI ${device.rssi}')),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              device.id,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppPalette.textSecondary),
            ),
            if (device.advertisedServices.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Advertised services: ${device.advertisedServices.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppPalette.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: device.connectable ? onConnect : null,
                    child: Text(
                      isConnected ? 'Reconnect' : 'Connect & Open Dashboard',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: null,
                    child: Text(
                      device.connectable ? 'Awaiting bind' : 'Not connectable',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final ProtocolProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    profile.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Chip(label: Text(profile.verified ? 'Verified' : 'Pending')),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              profile.family,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
            ),
            const SizedBox(height: 10),
            Text(profile.note, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
