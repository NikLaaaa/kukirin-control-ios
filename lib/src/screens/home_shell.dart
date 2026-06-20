import 'package:flutter/material.dart';

import '../controllers/scooter_app_controller.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'devices_screen.dart';
import 'protocol_screen.dart';

class KukirinHomeShell extends StatelessWidget {
  const KukirinHomeShell({super.key, required this.controller});

  final ScooterAppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            children: [
              const _AtmosphereBackground(),
              SafeArea(
                child: IndexedStack(
                  index: controller.selectedTab,
                  children: [
                    DevicesScreen(controller: controller),
                    DashboardScreen(controller: controller),
                    ProtocolScreen(controller: controller),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.selectedTab,
            onDestinationSelected: controller.setSelectedTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.bluetooth_searching_outlined),
                selectedIcon: Icon(Icons.bluetooth_searching),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.memory_outlined),
                selectedIcon: Icon(Icons.memory),
                label: 'Protocol',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AtmosphereBackground extends StatelessWidget {
  const _AtmosphereBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppPalette.accent.withValues(alpha: 0.36),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppPalette.accentWarm.withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
