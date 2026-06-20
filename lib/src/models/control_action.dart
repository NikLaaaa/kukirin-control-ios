enum ControlActionKind {
  lock,
  unlock,

  ecoMode,
  driveMode,
  sportMode,

  childModeOn,
  childModeOff,

  adjustAccelerator,
  resetOdom,

  lights,
  horn,

  singleMotor,
  dualMotor,
}

extension ControlActionKindX on ControlActionKind {
  String get label => switch (this) {
    ControlActionKind.lock => 'Lock',
    ControlActionKind.unlock => 'Unlock',
    ControlActionKind.lights => 'Lights',
    ControlActionKind.ecoMode => 'Eco',
    ControlActionKind.driveMode => 'Sport',
    ControlActionKind.sportMode => 'Race',
    ControlActionKind.horn => 'Horn',
    ControlActionKind.singleMotor => 'Single Motor',
    ControlActionKind.dualMotor => 'Dual Motor',
  };

  String get draftToken => switch (this) {
    ControlActionKind.lock => 'CMD_LOCK',
    ControlActionKind.unlock => 'CMD_UNLOCK',
    ControlActionKind.lights => 'CMD_LIGHTS',
    ControlActionKind.ecoMode => 'CMD_MODE_ECO',
    ControlActionKind.driveMode => 'CMD_MODE_DRIVE',
    ControlActionKind.sportMode => 'CMD_MODE_SPORT',
    ControlActionKind.horn => 'CMD_HORN',
    ControlActionKind.singleMotor => 'CMD_SINGLE_MOTOR',
    ControlActionKind.dualMotor => 'CMD_DUAL_MOTOR',
  };
}
