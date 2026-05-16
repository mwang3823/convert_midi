# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter build apk        # Build Android APK
flutter build ios        # Build iOS (requires Mac + Xcode)
flutter analyze          # Static analysis / lint
flutter test             # Run all tests
flutter test test/widget_test.dart  # Run a single test file
```

## Architecture

The app is a **MIDI-over-Bluetooth-LE streamer**: it scans for BLE devices, connects to one, then streams MIDI events from bundled `.mid` files to the device in real time.

### Data flow

```
assets/audio/*.mid
    → MidiStreamingService (parse + schedule events)
        → BluetoothService.sendRawData()  (BLE write-without-response)
            → connected BLE characteristic
```

### Key layers

| File | Role |
|------|------|
| `lib/libs/bluetooth_service.dart` | Wraps `flutter_blue_plus`: scan, connect, discover writable characteristic, send raw bytes |
| `lib/libs/midi_streaming_service.dart` | Parses MIDI with `dart_midi_pro`, iterates events with delta-time delays, fires callback for each NoteOn/NoteOff |
| `lib/screens/bluetooth_scanner_screen.dart` | Entry screen — scans and lists BLE devices, navigates to PlayerScreen on connect |
| `lib/screens/player_screen.dart` | Shows track list, controls play/stop, wires `MidiStreamingService` callback → `BluetoothService.sendRawData` |
| `lib/common/assets.dart` | Static registry of MIDI files (name + asset path) |

### Important implementation details

- **Single writable characteristic**: `connectToDevice` takes the *first* characteristic that supports write/writeWithoutResponse — sufficient for demo but not BLE-MIDI UUID-specific.
- **Tempo handling**: `MidiStreamingService.playStream` starts at 120 BPM (500 000 µs/beat) and updates live from `SetTempoEvent`. It merges all tracks into a flat event list; true multi-track playback would require separate per-track timing.
- **BLE write mode**: uses `withoutResponse: true` on every send to minimise latency.
- **`BluetoothService` is injected** from `main.dart` and passed down to both screens — there is no global state manager or DI framework.

### Adding MIDI files

1. Place the `.mid` file in `assets/audio/`.
2. Add an entry to `lib/common/assets.dart` (`Assets.midiFiles`).
3. `pubspec.yaml` already declares `assets/audio/` as a directory asset, so no further config is needed.
