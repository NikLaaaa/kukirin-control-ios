# KuKirin Link

KuKirin Link is an iOS-first Flutter application scaffold for KuKirin electric scooters. It already includes:

- BLE device scanning and connection flow
- A polished scooter dashboard UI
- Live FFF0 BLE profile with FFF1 writes and FFF2 notification subscription
- Quick control buttons for lock, unlock, and ride modes
- Ride setting toggles for cruise control and zero start
- A protocol lab screen for inspecting discovered GATT services and characteristics
- Demo mode so the product can be shown before live protocol binding is finished

## What is finished

- Flutter project created for iOS only
- BLE layer split into a repository
- KuKirin command and telemetry logic split into a protocol service
- UI architecture prepared for multiple scooter model families
- Live command packets wired for:
  - `F041` lock
  - `F042` unlock
  - `F04C0200` and `F04C0201` zero start off/on
  - `F04C0301`, `F04C0302`, `F04C0303` for Eco, Sport, Race
  - `F04C1300` and `F04C1301` cruise off/on
- iOS Bluetooth permission strings added to `Info.plist`
- Unit tests for live packet encoding and conservative telemetry decoding

## What still needs real scooter verification

The project now sends only the packets that were explicitly mapped. Remaining controls stay blocked on live sessions instead of sending guessed data.

Before the full KuKirin controller can be called production ready, you still need:

1. Real FFF2 notification samples from your target models to confirm telemetry byte layout
2. Model-by-model confirmation for speed, voltage, odometer, RPM, lock, cruise, and zero-start fields
3. Packet mapping for the still-disabled live actions like lights, horn, and motor switching
4. Validation that the same `FFF0 / FFF1 / FFF2` service family is shared across all KuKirin dashboards you want to support

When that data is available, extend:

- `lib/src/services/kukirin_protocol_service.dart`
- `lib/src/models/protocol_profile.dart`

## Why `flutter_reactive_ble`

I avoided `flutter_blue_plus` because its current package README states commercial usage requires a paid license.

This scaffold uses `flutter_reactive_ble`, which is published under BSD-3-Clause and is a cleaner fit for a business project.

## Project structure

```text
lib/
  src/
    app.dart
    controllers/
    models/
    screens/
    services/
    theme/
```

## Local development on Windows

Flutter is installed at:

```powershell
C:\flutter
```

This machine currently has Flutter available, but `flutter` is not yet on `PATH`.

Use:

```powershell
& 'C:\flutter\bin\flutter.bat' pub get
& 'C:\flutter\bin\flutter.bat' analyze
& 'C:\flutter\bin\flutter.bat' test
```

## Run the GUI on this Windows PC

This project now includes a Windows preview build so you can open the interface on the PC in demo mode.

1. Enable Windows Developer Mode once:

```powershell
start ms-settings:developers
```

2. Turn on `Developer Mode` in Windows settings.

3. Run the app:

```powershell
cd C:\Users\sss\Documents\Codex\2026-06-20\new-chat\outputs\kukirin_control_ios
& 'C:\flutter\bin\flutter.bat' run -d windows
```

The Windows build is a GUI preview only:

- it auto-starts in demo mode
- it shows the real app interface
- it does not use live KuKirin Bluetooth on Windows

## Run the GUI in a browser on this Windows PC

If Visual Studio Build Tools are not ready yet, use the web preview instead:

```powershell
cd C:\Users\sss\Documents\Codex\2026-06-20\new-chat\outputs\kukirin_control_ios
& 'C:\flutter\bin\flutter.bat' build web
python -m http.server 7357 --directory build\web
```

Then open:

```text
http://127.0.0.1:7357
```

The browser build is also preview-only and starts in demo mode automatically.

## Build on Mac as `.ipa`

1. Copy or clone this project to the Mac.
2. Run `flutter pub get`.
3. Open `ios/Runner.xcworkspace` in Xcode.
4. Set your Apple Developer team and signing settings.
5. Plug in an iPhone and test Bluetooth permissions and scanning.
6. Build an archive in Xcode or run:

```bash
flutter build ipa
```

## Recommended next milestone

Connect one real KuKirin model, open the Protocol Lab screen, and capture a few raw FFF2 packets while changing speed, mode, cruise, and lock state. That is the missing step between the current live command build and a fully verified production telemetry controller.
