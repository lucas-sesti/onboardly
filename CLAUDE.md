# Onboardly

Flutter package for creating onboarding experiences with spotlight effects and interactive tooltips.

## Project Structure

```
lib/
├── onboardly.dart              # Barrel file (exports all public APIs)
├── onboarding/                 # Onboarding flow system
│   ├── onboarding_controller.dart   # State management for onboarding steps
│   ├── onboarding_overlay.dart      # Overlay widget for the onboarding flow
│   ├── onboarding_skip_sheet.dart   # Bottom sheet for skipping onboarding
│   ├── onboarding_step.dart         # Step model/configuration
│   └── onboarding_tooltip.dart      # Tooltip widget for each step
├── spotlight/                  # Spotlight highlight system
│   ├── spotlight_controller.dart    # State management for spotlight
│   ├── spotlight_overlay.dart       # Overlay widget for spotlight effect
│   ├── spotlight_painter.dart       # Custom painter for the spotlight cutout
│   ├── spotlight_target.dart        # Target model/configuration
│   └── spotlight_touch_layer.dart   # Touch handling layer
example/                        # Example Flutter app demonstrating usage
test/                           # Unit and widget tests
```

## Rules

- **Read-only access to `lib/`**: Only read source files in `lib/` to understand context. Do NOT modify files in `lib/` unless explicitly asked.
- **Public API**: All public exports are defined in `lib/onboardly.dart`. Any new public file must be added there.
- **Dependencies**: The only external dependency is `provider`. Do not add new dependencies without asking.
- **SDK**: Dart SDK ^3.11.0, Flutter >=1.17.0.
- **Tests**: Tests live in `test/`, mirroring the `lib/` structure. Run tests with `flutter test`.
- **Example app**: The `example/` directory is a standalone Flutter app. Do not modify platform-specific folders (`android/`, `ios/`, `web/`, etc.) unless necessary.
- **Linting**: Uses `flutter_lints`. Run `dart analyze` before committing.
- **No comments in code** unless the logic is extremely complex and non-obvious.
- **CHANGELOG**: Whenever the version in `pubspec.yaml` is bumped, add an entry in `CHANGELOG.md` describing what was changed. Follow the existing format (version header + list of changes).

## Useful Commands

```bash
flutter test                # Run all tests
dart analyze                # Run static analysis
dart format .               # Format code
flutter pub get             # Get dependencies
cd example && flutter run   # Run example app
```
