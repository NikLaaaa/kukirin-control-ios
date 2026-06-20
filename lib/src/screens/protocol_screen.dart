import 'package:flutter/material.dart';

import '../controllers/scooter_app_controller.dart';
import '../models/gatt_map.dart';
import '../theme/app_theme.dart';

class ProtocolScreen extends StatelessWidget {
  const ProtocolScreen({super.key, required this.controller});

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
                'Protocol Lab',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This screen is where we finish the real business logic: choose a model family, inspect discovered services, and wire verified BLE packets.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppPalette.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Profile',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: controller.activeProfile.id,
                        items: controller.availableProfiles
                            .map(
                              (profile) => DropdownMenuItem<String>(
                                value: profile.id,
                                child: Text(profile.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectProfile(value);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      Text(
                        controller.activeProfile.note,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppPalette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          Chip(
                            label: Text(
                              controller.activeProfile.verified
                                  ? 'Verified for live commands'
                                  : 'Pending reverse engineering',
                            ),
                          ),
                          Chip(
                            label: Text(
                              controller.activeProfile.isBindable
                                  ? 'UUIDs present'
                                  : 'UUID mapping missing',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Draft Command Preview',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      _KeyValue(
                        label: 'Last action',
                        value: controller.lastActionLabel,
                      ),
                      const SizedBox(height: 8),
                      _KeyValue(
                        label: 'Draft frame',
                        value: controller.draftPreview,
                      ),
                      const SizedBox(height: 8),
                      _KeyValue(
                        label: 'Last packet seen',
                        value:
                            controller.snapshot.lastPacketHex ??
                            'No notifications captured yet.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Discovered GATT Map',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              if (controller.discoveredServices.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      'Connect a real scooter to populate services and characteristics here. This is the fastest path to finishing real KuKirin support.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ),
                ),
              for (final service in controller.discoveredServices) ...[
                _ServiceCard(service: service),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What Still Needs To Be Verified',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      const _BulletLine(
                        text:
                            'The official KuKirin app or dashboard traffic must be captured once per model family to identify write and notify characteristics.',
                      ),
                      const _BulletLine(
                        text:
                            'Telemetry packets need field mapping for speed, voltage, lock state, mode, cruise control, and motor configuration.',
                      ),
                      const _BulletLine(
                        text:
                            'After UUIDs are verified, replace the placeholders in KuKirinProtocolService.encodeCommand() and decodeTelemetry().',
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final GattServiceInfo service;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.uuid,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (service.characteristics.isEmpty)
              Text(
                'No characteristics discovered.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPalette.textSecondary,
                ),
              ),
            for (final characteristic in service.characteristics) ...[
              _KeyValue(
                label: characteristic.uuid,
                value: characteristic.capabilities,
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppPalette.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7, right: 10),
            child: Icon(Icons.circle, size: 8, color: AppPalette.accent),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
