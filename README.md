# Onboardly

A Flutter package for creating beautiful and customizable onboarding experiences with spotlight effects and interactive tooltips.

## Features

- ✅ **Spotlight Effect** - Highlight specific UI elements with customizable overlays
- ✅ **Interactive Tooltips** - Show descriptive tooltips with customizable positioning
- ✅ **Step-by-step Onboarding** - Guide users through multiple steps
- ✅ **State Management Agnostic** - Works with any state management solution or none at all
- ✅ **Fully Customizable** - Custom styles, colors, animations, and layouts
- ✅ **Skip Confirmation** - Built-in bottom sheet for skip confirmation
- ✅ **Callbacks** - Track onboarding progress with callbacks
- ✅ **Zero External Dependencies** - Only uses Flutter SDK

## Demo

<div align="center">
  <img src="https://res.cloudinary.com/seeken/image/upload/v1772667403/RocketSim_Recording_iPhone_Air_6.6_2026-03-05_00.35.40-ezgif.com-video-to-gif-converter_o0lvas.gif" alt="Onboardly Demo" width="300">
  <br/>
  <img src="https://res.cloudinary.com/seeken/image/upload/v1772667170/RocketSim_Screenshot_iPhone_Air_6.6_2026-03-05_00.07.35_lzadlj.jpg" alt="Onboardly Screenshot" width="300">
</div>

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  onboardly: ^2.0.0
```

## Getting Started

### 1. Create Services

Create instances of `SpotlightService` and `OnboardingService` in your widget state:

```dart
import 'package:onboardly/onboardly.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // Create services
  late final SpotlightService _spotlightService;
  late final OnboardingService _onboardingService;

  // Create GlobalKeys for the widgets you want to highlight
  final GlobalKey _buttonKey = GlobalKey();
  final GlobalKey _titleKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _spotlightService = SpotlightService();
    _onboardingService = OnboardingService(_spotlightService);
  }

  // ... rest of your code
}
```

### 2. Start Onboarding

```dart
void _startOnboarding() {
  final steps = [
    OnboardingStep(
      targetKey: _titleKey,
      description: 'This is the app title!',
      position: OnboardingTooltipPosition.below,
    ),
    OnboardingStep(
      targetKey: _buttonKey,
      description: 'Click here to continue.',
      position: OnboardingTooltipPosition.above,
    ),
  ];

  _onboardingService.start(
    context,
    steps,
    onFinish: () => print('Onboarding finished!'),
    onSkip: () => print('Onboarding skipped!'),
  );
}
```

## Usage

### Basic Onboarding

```dart
import 'package:onboardly/onboardly.dart';

final steps = [
  OnboardingStep(
    targetKey: _myWidgetKey,
    description: 'Welcome to our app!',
    position: OnboardingTooltipPosition.below,
  ),
];

_onboardingService.start(context, steps);
```

### With Callbacks

```dart
_onboardingService.start(
  context,
  steps,
  onStepChanged: (index) {
    print('Current step: $index');
  },
  onFinish: () {
    print('User completed the onboarding');
  },
  onSkip: () {
    print('User skipped the onboarding');
  },
);
```

### Spotlight Only (without tooltips)

```dart
final targets = [
  SpotlightTarget.fromKey(
    _myWidgetKey,
    padding: EdgeInsets.all(8),
    borderRadius: 12,
  ),
];

await _spotlightService.show(
  context,
  targets: targets,
  style: SpotlightStyle(
    scrimColor: Color.fromRGBO(0, 0, 0, 0.8),
    blurSigma: 3,
  ),
);
```

### Custom Skip Sheet

You can customize the skip confirmation sheet texts directly when starting the onboarding:

```dart
_onboardingService.start(
  context,
  steps,
  skipSheetTitle: 'Are you sure you want to skip?',
  skipSheetContinueButtonText: 'Continue tutorial',
  skipSheetSkipButtonText: 'Skip tutorial',
);
```

Or provide custom widgets by creating your own skip sheet:

```dart
// In your own skip sheet widget
OnboardingSkipSheet(
  titleWidget: MyCustomTitle(),
  continueButtonWidget: MyCustomButton(),
  skipButtonWidget: MyCustomButton(),
)
```

## State Management

Onboardly is **completely state-management agnostic**. You can use it with:

- **Local state** (StatefulWidget) - Simplest approach, recommended for most cases
- **InheritedWidget** - For sharing services across multiple widgets
- **Provider, Riverpod, Bloc, GetIt** - Any dependency injection or state management solution
- **No state management** - Just create instances where needed

The services are simple Dart classes with imperative APIs (`start()`, `next()`, `finish()`, etc.) and callbacks. They don't require any specific state management setup.

### Example with GetIt

```dart
// Register services
getIt.registerSingleton(SpotlightService());
getIt.registerSingleton(OnboardingService(getIt<SpotlightService>()));

// Use anywhere
final onboarding = getIt<OnboardingService>();
onboarding.start(context, steps);
```

### Example with Riverpod

```dart
final spotlightProvider = Provider((ref) => SpotlightService());
final onboardingProvider = Provider((ref) =>
  OnboardingService(ref.read(spotlightProvider))
);

// Use in widgets
final onboarding = ref.read(onboardingProvider);
onboarding.start(context, steps);
```

## API Reference

### OnboardingService

Main service for managing onboarding flows.

**Methods:**
- `start(BuildContext, List<OnboardingStep>, {...})` - Start the onboarding
  - `onStepChanged: (int index) => void` - Callback when step changes
  - `onFinish: () => void` - Callback when onboarding finishes
  - `onSkip: () => void` - Callback when onboarding is skipped
  - `defaultSpotlightHorizontalPadding: double` - Default horizontal padding for spotlight
  - `skipSheetTitle: String?` - Custom title for skip confirmation sheet
  - `skipSheetContinueButtonText: String?` - Custom text for continue button
  - `skipSheetSkipButtonText: String?` - Custom text for skip button
- `next()` - Move to next step
- `skip()` - Skip onboarding with confirmation
- `finish()` - Complete onboarding
- `dismissSilently()` - Dismiss without callbacks

**Properties:**
- `isActive` - Whether onboarding is currently active
- `currentIndex` - Current step index
- `currentStep` - Current OnboardingStep

### SpotlightService

Service for showing spotlight effects.

**Methods:**
- `show(BuildContext, {targets, extraHoles, style})` - Show spotlight
- `hide()` - Hide spotlight

**Properties:**
- `isShowing` - Whether spotlight is currently visible

### OnboardingStep

Configuration for each onboarding step.

```dart
OnboardingStep(
  targetKey: GlobalKey,           // Required: Widget to highlight
  description: String,             // Required: Description text
  position: OnboardingTooltipPosition, // Required: Tooltip position
)
```

**Tooltip Positions:**
- `OnboardingTooltipPosition.above`
- `OnboardingTooltipPosition.below`

### SpotlightTarget

Configuration for spotlight targets.

```dart
SpotlightTarget.fromKey(
  GlobalKey,                    // Required: Widget to highlight
  padding: EdgeInsets,         // Optional: Padding around target
  borderRadius: double,        // Optional: Border radius
  customBorderRadius: BorderRadius?, // Optional: Custom border radius
  customPath: Path?,           // Optional: Custom shape path
  maxHeight: double?,          // Optional: Maximum height
  customWidth: double?,        // Optional: Custom width
  allowTouchThrough: bool,     // Optional: Allow touches through (default: true)
)
```

### SpotlightStyle

Customize the spotlight appearance.

```dart
SpotlightStyle(
  blurSigma: 2.0,                           // Blur intensity
  scrimColor: Color.fromARGB(60, 0, 0, 0), // Overlay color
  animationDuration: Duration(milliseconds: 300), // Animation duration
)
```

## Examples

Check the [example](example/lib/main.dart) folder for a complete working example with:
- Full onboarding flow with 6 steps
- Quick onboarding with 2 steps
- Spotlight-only mode
- Custom callbacks and styling

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
