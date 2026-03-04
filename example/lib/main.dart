import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onboardly/spotlight/spotlight_controller.dart';
import 'package:onboardly/spotlight/spotlight_target.dart';
import 'package:onboardly/onboarding/onboarding_controller.dart';
import 'package:onboardly/onboarding/onboarding_step.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Providers setup - REQUIRED to use the package
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SpotlightService(),
        ),
        ChangeNotifierProvider(
          create: (context) => OnboardingService(
            context.read<SpotlightService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Onboardly Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const ExampleScreen(),
      ),
    );
  }
}

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  // GlobalKeys to identify widgets that will be highlighted
  final GlobalKey _appBarKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _button1Key = GlobalKey();
  final GlobalKey _button2Key = GlobalKey();
  final GlobalKey _button3Key = GlobalKey();
  final GlobalKey _cardKey = GlobalKey();

  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: _appBarKey,
        title: const Text('Onboardly - Complete Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
            tooltip: 'Information',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome card
            Card(
              key: _cardKey,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.celebration,
                      size: 48,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Welcome to Onboardly!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Counter: $_counter',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Onboarding examples section
            const Text(
              'Onboarding Examples:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              key: _button1Key,
              onPressed: _startFullOnboarding,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Complete Onboarding'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              key: _button2Key,
              onPressed: _startQuickOnboarding,
              icon: const Icon(Icons.fast_forward),
              label: const Text('Quick Onboarding (2 steps)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              key: _button3Key,
              onPressed: _showSpotlightOnly,
              icon: const Icon(Icons.highlight),
              label: const Text('Spotlight Only (no tooltip)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Package information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'About Onboardly',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• State management with Provider\n'
                    '• Customizable spotlight\n'
                    '• Positionable tooltips\n'
                    '• Callbacks for each step\n'
                    '• Customizable confirmation bottom sheet',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: () {
          setState(() {
            _counter++;
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Example 1: Complete onboarding with all elements
  void _startFullOnboarding() {
    final onboardingService = context.read<OnboardingService>();

    final steps = [
      OnboardingStep(
        targetKey: _appBarKey,
        description: '🎯 This is the application AppBar.\n'
            'Here you find the title and important actions.',
        position: OnboardingTooltipPosition.below,
      ),
      OnboardingStep(
        targetKey: _cardKey,
        description: '📊 This card shows important information.\n'
            'The counter is updated when you click the FAB.',
        position: OnboardingTooltipPosition.below,
      ),
      OnboardingStep(
        targetKey: _button1Key,
        description: '▶️ This button starts the complete tutorial\n'
            'with all onboarding steps.',
        position: OnboardingTooltipPosition.below,
      ),
      OnboardingStep(
        targetKey: _button2Key,
        description: '⚡ Quick version of onboarding\n'
            'with only the main points.',
        position: OnboardingTooltipPosition.below,
      ),
      OnboardingStep(
        targetKey: _button3Key,
        description: '💡 Shows only the spotlight\n'
            'without explanatory tooltip.',
        position: OnboardingTooltipPosition.above,
      ),
      OnboardingStep(
        targetKey: _fabKey,
        description: '➕ Use this button to increment the counter!\n'
            'This is the last step of the tutorial.',
        position: OnboardingTooltipPosition.above,
      ),
    ];

    onboardingService.start(
      context,
      steps,
      onStepChanged: (index) {
        debugPrint('📍 Changed to step: $index');
      },
      onFinish: () {
        debugPrint('✅ Onboarding finished!');
        _showSnackBar('Tutorial complete! 🎉');
      },
      onSkip: () {
        debugPrint('⏭️ Onboarding skipped!');
        _showSnackBar('Tutorial skipped');
      },
      // Skip sheet customization
      skipSheetTitle: 'Are you sure you want to skip the tutorial?',
      skipSheetContinueButtonText: 'Continue learning',
      skipSheetSkipButtonText: 'Skip for now',
    );
  }

  /// Example 2: Quick onboarding with only 2 steps
  void _startQuickOnboarding() {
    final onboardingService = context.read<OnboardingService>();

    final steps = [
      OnboardingStep(
        targetKey: _cardKey,
        description: '👋 Welcome! This is the main card.',
        position: OnboardingTooltipPosition.below,
      ),
      OnboardingStep(
        targetKey: _fabKey,
        description: '✨ Click here to increment!',
        position: OnboardingTooltipPosition.above,
      ),
    ];

    onboardingService.start(
      context,
      steps,
      onFinish: () => _showSnackBar('Quick tutorial completed! ⚡'),
      onSkip: () => _showSnackBar('Quick tutorial skipped'),
      // Example with English text
      skipSheetTitle: 'Skip the quick tour?',
      skipSheetContinueButtonText: 'Keep learning',
      skipSheetSkipButtonText: 'Skip',
    );
  }

  /// Example 3: Use only the spotlight without tooltip
  void _showSpotlightOnly() async {
    final spotlightService = context.read<SpotlightService>();

    // Create targets using GlobalKeys
    final targets = [
      SpotlightTarget.fromKey(
        _cardKey,
        padding: const EdgeInsets.all(12),
        borderRadius: 12,
      ),
      SpotlightTarget.fromKey(
        _fabKey,
        padding: const EdgeInsets.all(8),
        borderRadius: 28, // circular for FAB
      ),
    ];

    await spotlightService.show(
      context,
      targets: targets,
      style: const SpotlightStyle(
        scrimColor: Color.fromRGBO(0, 0, 0, 0.85),
        blurSigma: 3,
        animationDuration: Duration(milliseconds: 400),
      ),
    );

    _showSnackBar('Tap the screen to close the spotlight');

    // Auto-close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (spotlightService.isShowing) {
        spotlightService.hide();
      }
    });
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Onboardly'),
        content: const Text(
          'This is a complete example of the Onboardly package.\n\n'
          'Features:\n'
          '• Onboarding with multiple steps\n'
          '• Customizable spotlight\n'
          '• Explanatory tooltips\n'
          '• Callbacks for events\n'
          '• Management via Provider\n\n'
          'Try the different buttons to see the features!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startFullOnboarding();
            },
            child: const Text('Start Tutorial'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
