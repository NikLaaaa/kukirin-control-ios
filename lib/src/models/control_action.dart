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

    ControlActionKind.ecoMode => 'Eco',
    ControlActionKind.driveMode => 'Sport',
    ControlActionKind.sportMode => 'Race',

    ControlActionKind.childModeOn => 'Child Mode ON',
    ControlActionKind.childModeOff => 'Child Mode OFF',

    ControlActionKind.adjustAccelerator => 'Adjust Accelerator',
    ControlActionKind.resetOdom => 'Reset ODM',

    ControlActionKind.lights => 'Lights',
    ControlActionKind.horn => 'Horn',

    ControlActionKind.singleMotor => 'Single Motor',
    ControlActionKind.dualMotor => 'Dual Motor',
  };

  String get draftToken => switch (this) {
    ControlActionKind.lock => 'F041',
    ControlActionKind.unlock => 'F042',

    ControlActionKind.ecoMode => 'F04C0301',
    ControlActionKind.driveMode => 'F04C0302',
    ControlActionKind.sportMode => 'F04C0303',

    ControlActionKind.childModeOn =>
        'F052033216CC003219F500321CF500',

    ControlActionKind.childModeOff =>
        'F052033216F50032199801321CA602',

    ControlActionKind.adjustAccelerator =>
        'F04B00B400B9008701CC01',

    ControlActionKind.resetOdom =>
        'F066FF',

    ControlActionKind.lights => 'CMD_LIGHTS',
    ControlActionKind.horn => 'CMD_HORN',

    ControlActionKind.singleMotor => 'CMD_SINGLE_MOTOR',
    ControlActionKind.dualMotor => 'CMD_DUAL_MOTOR',
  };
}
