# KuKirin Link

KuKirin Link is an iOS-first Flutter application scaffold for KuKirin electric scooters. It already includes:

- BLE device scanning and connection flow
- A polished scooter dashboard UI
- Quick control buttons for lock, lights, horn, ride modes, and motor mode
- Ride setting toggles for cruise control, zero start, and single motor mode
- A protocol lab screen for inspecting discovered GATT services and characteristics
- Demo mode so the product can be shown before live protocol binding is finished

## What is finished

- Flutter project created for iOS only
- BLE layer split into a repository
- KuKirin command and telemetry logic split into a protocol service
- UI architecture prepared for multiple scooter model families
- iOS Bluetooth permission strings added to `Info.plist`
- Unit tests for the demo protocol helpers

## What still needs real scooter verification

The project is intentionally safe for business use: it does not send guessed packets to a real scooter yet.

Before live KuKirin control can be enabled for a specific model family, you still need:

1. A real BLE capture from the official KuKirin app or from the scooter dashboard session
2. Verified service UUID, write characteristic UUID, and notify characteristic UUID
3. Packet mapping for telemetry fields like speed, voltage, ride mode, lock state, and settings
4. Packet mapping for write actions like lock, unlock, lights, horn, cruise, zero start, and motor mode

When that data is available, replace the placeholders in:

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

Connect one real KuKirin model, open the Protocol Lab screen, inspect discovered services, and capture the official app traffic. That is the missing step between this scaffold and a true production BLE controller.
