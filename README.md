# flutter_dtmf_pro

A compact Flutter plugin to generate DTMF (Dual-Tone Multi-Frequency) tones. Use it to play telephone keypad tones (0–9, A–D, *, #) from your Flutter app.

**Platforms:** Android, iOS, Web (when a web implementation is available in this package).

**License:** MIT — see the `LICENSE` file.

**Overview**

This plugin provides a lightweight API for producing DTMF tones on supported platforms. It is intended for apps that need to emit dial-pad tones (for example, to interact with IVR systems or to provide audio feedback in VoIP applications).

**Quick install**

Add the package to your `pubspec.yaml` (for local testing or development):

```yaml
dependencies:
	flutter_dtmf_pro:
		path: .
```

Then:

```bash
flutter pub get
```

**Basic usage**

Import the plugin and call the provided API. The exact API names (class/function) may vary by version — check the library exports in `lib/` if in doubt.

```dart
import 'package:flutter_dtmf_pro/flutter_dtmf_pro.dart';

// Example: play a short sequence
await Dtmf.playTone(
	digits: '123#',
	durationMs: 200,
	volume: 0.8,
);
```

See the `example/` app for a working demonstration.

**Android notes**
- Uses Android's `ToneGenerator` API.
- By default the plugin respects the device DTMF system setting; callers can choose to ignore the setting if needed.
- The native Kotlin code is compatible with JVM target 1.8 (and higher).

**Contributing**

- Bug reports and PRs are welcome. Open issues on the repository and include steps to reproduce, platform, and Flutter version.
- Run the `example/` app when testing changes locally:

```bash
cd example
flutter run
```