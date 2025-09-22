# EcoMonitor — Frontend (Flutter)

Production-ready Flutter client for EcoMonitor. The app consumes the Backend API to visualize sensor data, devices and time-series charts.

This README documents how to set up the Flutter toolchain, run the app on emulators or devices, and produce build artifacts for release.

## Contents

- Overview
- Requirements
- Quick start (run)
- Configuration
- Common development tasks
- Troubleshooting
- Contributing

## Overview

The Frontend is implemented in Flutter (Dart) and provides a responsive UI to interact with EcoMonitor sensor data. It relies on the Backend API (see `Backend/README.md`) to fetch sensors, device lists and measurement data.

High-level layout:

- `lib/`: application source code (models, services, presentation, state)
- `pubspec.yaml`: dependencies and assets (images, fonts)
- platform folders: `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`

## Requirements

- Flutter SDK (stable channel) compatible with Dart 3.9+
- For mobile builds: Android SDK / Xcode (macOS) installed and configured

Install Flutter: https://docs.flutter.dev/get-started/install

Install dependencies:

```bash
cd Frontend
flutter pub get
```

## Quick start — Run the app locally

1. Ensure Flutter is installed and available in your PATH:

```bash
flutter --version
```

2. Install packages and run on a device/emulator:

```bash
cd Frontend
flutter pub get
flutter devices       # list available devices
flutter run           # run on the first available device
```

To run on Chrome (web):

```bash
flutter run -d chrome
```

Notes on connecting to the Backend API:

- Android emulator -> use `10.0.2.2` to reach the host machine's localhost
- iOS simulator -> use `localhost`
- When running on a physical device, use the machine IP reachable from the device (e.g., `192.168.1.10:5001`)

## Configuration

The app expects a configurable Backend base URL inside the API service or constants file (search for the API client in `lib/data` or `lib/core`). Update that value to point to your backend instance.

Default:

```dart
'http://127.0.0.1:5001;'
```

## Common development tasks

- Hot reload: press `r` while running with `flutter run` or use your IDE's hot reload action
- Unit & widget tests:

```bash
flutter test
```

- Build release APK (Android):

```bash
flutter build apk --release
```

- Build iOS (requires Xcode/macOS):

```bash
flutter build ios --release
```

- Build web release:

```bash
flutter build web --release
```

## Troubleshooting

- `flutter doctor -v` is your first tool — fix any issues it reports
- If `flutter pub get` fails, try `flutter pub cache repair` then `flutter pub get`
- If the app cannot reach the backend, verify the backend is running and that you are using the correct host/IP for the target platform (see Configuration notes)

## Contributing

1. Fork the repository and create a feature branch
2. Make changes and add tests where applicable
3. Run `flutter analyze` and `flutter test` locally
4. Open a PR with a clear description of changes and testing steps

---
Maintainers: EcoMonitor project
