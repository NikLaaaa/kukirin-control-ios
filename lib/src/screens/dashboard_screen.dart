import 'package:flutter/material.dart';

import '../controllers/scooter_app_controller.dart';
import '../models/control_action.dart';
import '../models/scooter_snapshot.dart';
import '../models/toggle_setting.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final ScooterAppController controller;

  @override
  Widget build(BuildContext context) {
    final snapshot = controller.snapshot;
    final settings = controller.rideSettings.values.toList();
    final controlsEnabled =
        controller.hasConnectedTransport && !controller.isApplyingChange;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                'KuKirin Link',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.isPreviewOnlyPlatform
                    ? 'Windows preview mode is active. The GUI is live here, while real Bluetooth control stays reserved for iPhone builds.'
                    : 'Open Search first, connect to a scooter, then use this dashboard for telemetry and controls.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppPalette.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _HeroPanel(controller: controller),
              if (!controller.hasConnectedTransport) ...[
                const SizedBox(height: 20),
                _ConnectPrompt(controller: controller),
              ] else ...[
                const SizedBox(height: 20),
                _SectionTitle(
                  title: 'Live Telemetry',
                  subtitle: snapshot.statusLine,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _MetricCard(
                      title: 'Mode',
                      value: snapshot.rideMode.label,
                      helper:
                          snapshot.cruiseEnabled ? 'Cruise on' : 'Cruise off',
                    ),
                    _MetricCard(
                      title: 'Voltage',
                      value: '${snapshot.voltage.toStringAsFixed(1)} V',
                      helper: controller.connectionLabel(),
                    ),
                    _MetricCard(
                      title: 'Speed',
                      value: '${snapshot.speedKmh.toStringAsFixed(1)} km/h',
                      helper: 'Battery ${snapshot.batteryPercent}%',
                    ),
                    _MetricCard(
                      title: 'Odometer',
                      value: '${snapshot.odometerKm.toStringAsFixed(1)} km',
                      helper: 'Zero start ${snapshot.zeroStartEnabled ? 'On' : 'Off'}',
                    ),
                    _MetricCard(
                      title: 'RPM',
                      value: '${snapshot.motorRpm}',
                      helper: 'Range ${snapshot.estimatedRangeKm.toStringAsFixed(0)} km',
                    ),
                    _MetricCard(
                      title: 'Lock State',
                      value: snapshot.locked ? 'Locked' : 'Unlocked',
                      helper: snapshot.locked ? 'Locked' : 'Unlocked',
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _SectionTitle(
                  title: 'Quick Controls',
                  subtitle:
                      'Mapped FFF1 commands send live to the scooter. Unmapped controls stay disabled on live sessions.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final action in _actions)
                      _ActionButton(
                        action: action,
                        enabled:
                            controlsEnabled &&
                            controller.supportsAction(action),
                        onTap: () => controller.sendAction(action),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                _SectionTitle(
                  title: 'Ride Settings',
                  subtitle:
                      'Cruise and zero start write live packets. Unmapped settings stay disabled during live sessions.',
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index < settings.length;
                          index++
                        ) ...[
                          _SettingTile(
                            setting: settings[index],
                            enabled:
                                controlsEnabled &&
                                controller.supportsRideSetting(
                                  settings[index].id,
                                ),
                            onChanged: (value) => controller.toggleRideSetting(
                              settings[index].id,
                              value,
                            ),
                          ),
                          if (index != settings.length - 1)
                            const Divider(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Session Notes',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          controller.statusMessage,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppPalette.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        _LabelValue(
                          label: 'Last draft packet',
                          value: controller.draftPreview,
                        ),
                        const SizedBox(height: 8),
                        _LabelValue(
                          label: 'Last action',
                          value: controller.lastActionLabel,
                        ),
                        const SizedBox(height: 8),
                        _LabelValue(
                          label: 'Operation',
                          value: controller.activeOperationLabel,
                        ),
                        const SizedBox(height: 8),
                        _LabelValue(
                          label: 'Last packet seen',
                          value:
                              snapshot.lastPacketHex ?? 'No live packets yet.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

const List<ControlActionKind> _actions = [
  ControlActionKind.lock,
  ControlActionKind.unlock,

  ControlActionKind.ecoMode,
  ControlActionKind.driveMode,
  ControlActionKind.sportMode,

  ControlActionKind.childModeOn,
  ControlActionKind.childModeOff,

  ControlActionKind.adjustAccelerator,
  ControlActionKind.resetOdom,
];

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.controller});

  final ScooterAppController controller;

  @override
  Widget build(BuildContext context) {
    final snapshot = controller.snapshot;
    final deviceName =
        controller.connectedDevice?.displayName ?? 'No scooter selected';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D876E), Color(0xFF123A5E), Color(0xFF2D1E3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.electric_scooter, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.connectionLabel(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.74),
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  controller.bleStatusLabel(),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            snapshot.locked ? 'Scooter locked' : 'Scooter ready to ride',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            snapshot.statusLine,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.isDemoMode
                      ? controller.disconnect
                      : controller.startDemoMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppPalette.background,
                  ),
                  child: Text(
                    controller.isDemoMode ? 'Stop Demo' : 'Launch Demo',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.hasConnectedTransport
                      ? controller.disconnect
                      : controller.setSelectedTab.bind(
                          ScooterAppController.searchTabIndex,
                        ),
                  child: Text(
                    controller.hasConnectedTransport
                        ? 'Disconnect'
                        : 'Open Search',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConnectPrompt extends StatelessWidget {
  const _ConnectPrompt({required this.controller});

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
              'Connect A Scooter First',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Start from the Search tab, find the KuKirin over Bluetooth, connect to it, and the app will open this dashboard automatically.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => controller.setSelectedTab(
                ScooterAppController.searchTabIndex,
              ),
              child: const Text('Go To Search Devices'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.helper,
  });

  final String title;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 164,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppPalette.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                helper,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppPalette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.action,
    required this.enabled,
    required this.onTap,
  });

  final ControlActionKind action;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 152,
      child: FilledButton.tonalIcon(
        onPressed: enabled ? onTap : null,
        icon: Icon(_iconForAction(action)),
        label: Text(action.label),
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.panelRaised,
          foregroundColor: AppPalette.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppPalette.stroke),
          ),
        ),
      ),
    );
  }

  IconData _iconForAction(ControlActionKind action) {
    return switch (action) {
      ControlActionKind.lock => Icons.lock_outline,
      ControlActionKind.unlock => Icons.lock_open_outlined,
      ControlActionKind.lights => Icons.light_mode_outlined,
      ControlActionKind.ecoMode => Icons.eco_outlined,
      ControlActionKind.driveMode => Icons.route_outlined,
      ControlActionKind.sportMode => Icons.local_fire_department_outlined,
      ControlActionKind.horn => Icons.campaign_outlined,
      ControlActionKind.singleMotor => Icons.flash_off_outlined,
      ControlActionKind.dualMotor => Icons.flash_on_outlined,
    };
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.setting,
    required this.enabled,
    required this.onChanged,
  });

  final ToggleSetting setting;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                setting.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                setting.subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPalette.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch(value: setting.value, onChanged: enabled ? onChanged : null),
      ],
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 132,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppPalette.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

extension on void Function(int) {
  VoidCallback bind(int value) {
    return () => this(value);
  }
}
