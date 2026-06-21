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
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFFFFF),
                  AppPalette.background,
                  Color(0xFFF1F3F6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: controller.selectedTab,
                children: [
                  DevicesScreen(controller: controller),
                  DashboardScreen(controller: controller),
                  ProtocolScreen(controller: controller),
                ],
              ),
            ),
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppPalette.panel,
              border: Border(
                top: BorderSide(color: AppPalette.stroke),
              ),
            ),
            child: SafeArea(
              top: false,
              child: NavigationBar(
                selectedIndex: controller.selectedTab,
                onDestinationSelected: controller.setSelectedTab,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.bluetooth_outlined),
                    selectedIcon: Icon(Icons.bluetooth),
                    label: 'Devices',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bolt_outlined),
                    selectedIcon: Icon(Icons.bolt),
                    label: 'Ride',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.tune_outlined),
                    selectedIcon: Icon(Icons.tune),
                    label: 'Protocol',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
