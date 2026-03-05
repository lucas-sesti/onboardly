## 2.0.0

**BREAKING CHANGES:**
* Removed `provider` dependency - package is now state-management agnostic
* `OnboardingService` and `SpotlightService` no longer extend `ChangeNotifier`
* Removed `OnboardingOverlay` widget (was unused and always returned empty widget)

**New Features:**
* Add support for `RenderSliver` widgets (e.g., `SliverAppBar`, `SliverPersistentHeader`)
* Spotlight and onboarding now work with widgets inside `NestedScrollView` and custom slivers
* Improved render object type detection with fallback to ancestor `RenderBox` when needed
* Add customizable tooltip button texts (`nextText`, `skipText`, `finishText`) with English defaults via `OnboardingService.start()`

**Migration Guide:**

Users should create service instances directly instead of using Provider:

**Before:**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => SpotlightService()),
    ChangeNotifierProvider(create: (context) =>
      OnboardingService(context.read<SpotlightService>())
    ),
  ],
  child: MaterialApp(...)
)
```

**After:**
```dart
class _MyAppState extends State<MyApp> {
  late final _spotlight = SpotlightService();
  late final _onboarding = OnboardingService(_spotlight);

  void _startOnboarding() {
    _onboarding.start(context, steps);
  }
}
```

Services can be managed with any state management solution (Provider, Riverpod, Bloc, GetIt, etc.) or simple local state.

**Benefits:**
* No external dependencies beyond Flutter SDK
* Works with any state management solution
* Simpler API and less boilerplate
* Smaller bundle size

## 1.0.3

* Update package dependencies and improve stability.

## 1.0.2

* Export core onboarding and spotlight components for easier access.
* Correct example link path in documentation.
* Remove GetX migration guide section from README.

## 1.0.1

* Initial stable release with core functionality.
* Beautiful and customizable onboarding experiences.
* Spotlight effects and interactive tooltips.
* Provider-based state management.

## 0.0.1

* Initial development release.
