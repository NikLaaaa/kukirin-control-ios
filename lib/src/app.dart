import 'package:flutter/material.dart';

import 'controllers/scooter_app_controller.dart';
import 'screens/home_shell.dart';
import 'services/ble_scooter_repository.dart';
import 'services/kukirin_protocol_service.dart';
import 'theme/app_theme.dart';

class KukirinControlApp extends StatefulWidget {
  const KukirinControlApp({super.key});

  @override
  State<KukirinControlApp> createState() => _KukirinControlAppState();
}

class _KukirinControlAppState extends State<KukirinControlApp> {
  late final ScooterAppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScooterAppController(
      bleRepository: BleScooterRepository(),
      protocolService: KuKirinProtocolService(),
    )..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KuKirin Link',
      theme: AppTheme.themeData,
      home: KukirinHomeShell(controller: _controller),
    );
  }
}
