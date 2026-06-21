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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 118),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _RideHeader(controller: controller),
              const SizedBox(height: 26),
              _SpeedReadout(snapshot: snapshot),
              const SizedBox(height: 22),
              _PrimaryMetrics(snapshot: snapshot),
              const SizedBox(height: 18),
              _BatteryBar(percent: snapshot.batteryPercent),
              const SizedBox(height: 22),
              _TripStats(snapshot: snapshot),
              const SizedBox(height: 22),
              _RideModeSelector(
                snapshot: snapshot,
                enabled: controlsEnabled,
                supportsAction: controller.supportsAction,
                onAction: controller.sendAction,
              ),
              const SizedBox(height: 18),
              _SettingsPanel(
                settings: settings,
                enabled: controlsEnabled,
                supportsRideSetting: controller.supportsRideSetting,
                onChanged: controller.toggleRideSetting,
              ),
              const SizedBox(height: 18),
              _ActionGrid(
                enabled: controlsEnabled,
                supportsAction: controller.supportsAction,
                onAction: controller.sendAction,
              ),
              const SizedBox(height: 18),
              if (!controller.hasConnectedTransport)
                _ConnectPrompt(controller: controller)
              else
                _SessionPanel(controller: controller, snapshot: snapshot),
            ]),
          ),
        ),
      ],
    );
  }
}

class _RideHeader extends StatelessWidget {
  const _RideHeader({required this.controller});

  final ScooterAppController controller;

  @override
  Widget build(BuildContext context) {
    final deviceName =
        controller.connectedDevice?.displayName ?? 'KuKirin Control';
    final isOnline = controller.hasConnectedTransport;

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Text(
              deviceName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color:
                        isOnline ? AppPalette.accentGreen : AppPalette.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  controller.connectionLabel(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppPalette.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () => controller.setSelectedTab(
              ScooterAppController.protocolTabIndex,
            ),
            icon: const Icon(Icons.settings_outlined),
            color: AppPalette.textPrimary,
            tooltip: 'Protocol',
          ),
        ),
      ],
    );
  }
}

class _SpeedReadout extends StatelessWidget {
  const _SpeedReadout({required this.snapshot});

  final ScooterSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final speed = snapshot.speedKmh.round().toString();

    return Column(
      children: [
        Text(
          speed,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 92,
            height: 0.9,
            fontWeight: FontWeight.w900,
            color: AppPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'km/h',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppPalette.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PrimaryMetrics extends StatelessWidget {
  const _PrimaryMetrics({required this.snapshot});

  final ScooterSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricValue(
            value: '${snapshot.voltage.toStringAsFixed(1)} V',
            label: 'Voltage',
          ),
        ),
        Container(width: 1, height: 44, color: AppPalette.stroke),
        Expanded(
          child: _MetricValue(
            value: '${snapshot.batteryPercent}%',
            label: 'Battery',
          ),
        ),
      ],
    );
  }
}

class _MetricValue extends StatelessWidget {
  const _MetricValue({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppPalette.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BatteryBar extends StatelessWidget {
  const _BatteryBar({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final value = (percent.clamp(0, 100)) / 100;

    return Container(
      height: 16,
      decoration: BoxDecoration(
        color: AppPalette.panelRaised,
        borderRadius: BorderRadius.circular(999),
      ),
      clipBehavior: Clip.antiAlias,
      child: FractionallySizedBox(
        widthFactor: value,
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppPalette.accentGreen, Color(0xFF35D178)],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _TripStats extends StatelessWidget {
  const _TripStats({required this.snapshot});

  final ScooterSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _CompactMetric(
              label: 'Range',
              value: '${snapshot.estimatedRangeKm.toStringAsFixed(0)} km',
            ),
          ),
          Container(width: 1, height: 34, color: AppPalette.stroke),
          Expanded(
            child: _CompactMetric(
              label: 'Trip',
              value: '${snapshot.tripKm.toStringAsFixed(1)} km',
            ),
          ),
          Container(width: 1, height: 34, color: AppPalette.stroke),
          Expanded(
            child: _CompactMetric(
              label: 'RPM',
              value: '${snapshot.motorRpm}',
            ),
          ),
        ],
      ),
    );
  }
}

class _RideModeSelector extends StatelessWidget {
  const _RideModeSelector({
    required this.snapshot,
    required this.enabled,
    required this.supportsAction,
    required this.onAction,
  });

  final ScooterSnapshot snapshot;
  final bool enabled;
  final bool Function(ControlActionKind action) supportsAction;
  final ValueChanged<ControlActionKind> onAction;

  @override
  Widget build(BuildContext context) {
    final modes = [
      _ModeOption('ECO', RideMode.eco, ControlActionKind.ecoMode),
      _ModeOption('SPORT', RideMode.drive, ControlActionKind.driveMode),
      _ModeOption('RACE', RideMode.sport, ControlActionKind.sportMode),
    ];

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppPalette.panelRaised,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final mode in modes)
            Expanded(
              child: _ModeButton(
                mode: mode,
                selected: snapshot.rideMode == mode.rideMode,
                enabled: enabled && supportsAction(mode.action),
                onTap: () => onAction(mode.action),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.mode,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final _ModeOption mode;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? AppPalette.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppPalette.accent.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              mode.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected
                    ? Colors.white
                    : enabled
                        ? AppPalette.textPrimary
                        : AppPalette.textTertiary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.settings,
    required this.enabled,
    required this.supportsRideSetting,
    required this.onChanged,
  });

  final List<ToggleSetting> settings;
  final bool enabled;
  final bool Function(ToggleSettingId id) supportsRideSetting;
  final void Function(ToggleSettingId id, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          for (var index = 0; index < settings.length; index++) ...[
            _SettingTile(
              setting: settings[index],
              enabled: enabled && supportsRideSetting(settings[index].id),
              onChanged: (value) => onChanged(settings[index].id, value),
            ),
            if (index != settings.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  setting.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  setting.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(value: setting.value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.enabled,
    required this.supportsAction,
    required this.onAction,
  });

  final bool enabled;
  final bool Function(ControlActionKind action) supportsAction;
  final ValueChanged<ControlActionKind> onAction;

  @override
  Widget build(BuildContext context) {
    const actions = [
      ControlActionKind.lock,
      ControlActionKind.unlock,
      ControlActionKind.lights,
      ControlActionKind.resetOdom,
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 84,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        return _ActionTile(
          action: action,
          enabled: enabled && supportsAction(action),
          onTap: () => onAction(action),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.action,
    required this.enabled,
    required this.onTap,
  });

  final ControlActionKind action;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _iconForAction(action),
                  color: enabled ? AppPalette.textPrimary : AppPalette.textTertiary,
                  size: 27,
                ),
                const SizedBox(height: 7),
                Text(
                  _shortLabel(action),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: enabled
                        ? AppPalette.textPrimary
                        : AppPalette.textTertiary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
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
      ControlActionKind.resetOdom => Icons.restart_alt,
      ControlActionKind.ecoMode => Icons.eco_outlined,
      ControlActionKind.driveMode => Icons.route_outlined,
      ControlActionKind.sportMode => Icons.local_fire_department_outlined,
      ControlActionKind.childModeOn => Icons.child_care,
      ControlActionKind.childModeOff => Icons.person_off,
      ControlActionKind.adjustAccelerator => Icons.speed,
      ControlActionKind.horn => Icons.campaign_outlined,
      ControlActionKind.singleMotor => Icons.flash_off_outlined,
      ControlActionKind.dualMotor => Icons.flash_on_outlined,
    };
  }

  String _shortLabel(ControlActionKind action) {
    return switch (action) {
      ControlActionKind.resetOdom => 'Reset',
      ControlActionKind.driveMode => 'Sport',
      ControlActionKind.sportMode => 'Race',
      ControlActionKind.childModeOn => 'Child On',
      ControlActionKind.childModeOff => 'Child Off',
      ControlActionKind.adjustAccelerator => 'Accel',
      ControlActionKind.singleMotor => 'Single',
      ControlActionKind.dualMotor => 'Dual',
      _ => action.label,
    };
  }
}

class _ConnectPrompt extends StatelessWidget {
  const _ConnectPrompt({required this.controller});

  final ScooterAppController controller;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready for preview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            controller.isPreviewOnlyPlatform
                ? 'Use demo mode here. Live Bluetooth control stays in the iPhone build.'
                : 'Connect a scooter from Devices, or launch demo mode to test the dashboard.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppPalette.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.startDemoMode,
                  child: const Text('Launch Demo'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.setSelectedTab(
                    ScooterAppController.searchTabIndex,
                  ),
                  child: const Text('Devices'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionPanel extends StatelessWidget {
  const _SessionPanel({required this.controller, required this.snapshot});

  final ScooterAppController controller;
  final ScooterSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Session',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.disconnect,
                child: const Text('Disconnect'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _LabelValue(label: 'Status', value: controller.statusMessage),
          _LabelValue(label: 'Last action', value: controller.lastActionLabel),
          _LabelValue(label: 'Packet', value: snapshot.lastPacketHex ?? 'None'),
        ],
      ),
    );
  }
}

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppPalette.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppPalette.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppPalette.textPrimary,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
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

class _ModeOption {
  const _ModeOption(this.label, this.rideMode, this.action);

  final String label;
  final RideMode rideMode;
  final ControlActionKind action;
}
