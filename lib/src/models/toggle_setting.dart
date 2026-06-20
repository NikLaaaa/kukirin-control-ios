enum ToggleSettingId { cruiseControl, zeroStart, singleMotorMode }

class ToggleSetting {
  const ToggleSetting({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final ToggleSettingId id;
  final String title;
  final String subtitle;
  final bool value;

  ToggleSetting copyWith({bool? value}) {
    return ToggleSetting(
      id: id,
      title: title,
      subtitle: subtitle,
      value: value ?? this.value,
    );
  }
}
