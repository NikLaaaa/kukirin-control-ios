import 'package:flutter/material.dart';

import '../controllers/scooter_app_controller.dart';
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
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 118),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                'Connect',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Scan for nearby devices',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppPalette.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isScanning
                      ? controller.stopScan
                      : controller.startScan,
                  icon: Icon(
                    controller.isScanning
                        ? Icons.pause_circle_filled
                        : Icons.radar,
                  ),
                  label: Text(controller.isScanning ? 'Stop Scan' : 'Scan'),
                ),
              ),
              const SizedBox(height: 14),
              _StatusStrip(controller: controller),
              const SizedBox(height: 32),
              _SectionHeader(
                title: 'Available Devices',
                trailing: controller.isScanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              const SizedBox(height: 14),
              if (controller.devices.isEmpty)
                _EmptyDevicePanel(controller: controller)
              else
                for (final device in controller.devices) ...[
                  _DeviceTile(
                    device: device,
                    isConnected: controller.connectedDevice?.id == device.id,
                    onConnect: () => controller.connectToDevice(device),
                  ),
                  const SizedBox(height: 10),
                ],
            ]),
          ),
        ),
      ],
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.controller});

  final ScooterAppController controller;

  @override
  Widget build(BuildContext context) {
    final isConnected = controller.hasConnectedTransport;

    return _SoftPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (isConnected ? AppPalette.accentGreen : AppPalette.accent)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isConnected ? Icons.check_circle : Icons.bluetooth_searching,
              color: isConnected ? AppPalette.accentGreen : AppPalette.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.connectionLabel(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  controller.statusMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppPalette.textSecondary,
                    height: 1.25,
                  ),
                ),
                if (controller.lastError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    controller.lastError!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPalette.accentDanger,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: controller.startDemoMode,
            child: const Text('Demo'),
          ),
        ],
      ),
    );
  }
}

class _EmptyDevicePanel extends StatelessWidget {
  const _EmptyDevicePanel({required this.controller});

  final ScooterAppController controller;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Icon(Icons.bluetooth_disabled, color: AppPalette.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.isScanning
                  ? 'Scanning is active. Keep the scooter awake and close to the phone.'
                  : 'No devices yet. Start a scan or open demo mode for a quick preview.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppPalette.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.device,
    required this.isConnected,
    required this.onConnect,
  });

  final ScooterDevice device;
  final bool isConnected;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final signalColor =
        device.rssi >= -55 ? AppPalette.accentGreen : AppPalette.textTertiary;

    return _SoftPanel(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: device.connectable ? onConnect : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppPalette.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.bluetooth,
                    color: AppPalette.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isConnected
                            ? 'Connected'
                            : device.looksLikeKukirin
                                ? 'KuKirin device'
                                : 'BLE peripheral',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isConnected
                              ? AppPalette.accentGreen
                              : AppPalette.textSecondary,
                          fontWeight:
                              isConnected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.signal_cellular_alt, color: signalColor, size: 18),
                const SizedBox(width: 5),
                SizedBox(
                  width: 34,
                  child: Text(
                    '${device.rssi}',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPalette.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppPalette.accent,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppPalette.textSecondary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SoftPanel extends StatelessWidget {
  const _SoftPanel({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppPalette.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.stroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
