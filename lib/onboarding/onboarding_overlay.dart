import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'onboarding_controller.dart';

class OnboardingOverlay extends StatelessWidget {
  const OnboardingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingService>(
      builder: (context, controller, child) {
        if (!controller.isActive) return const SizedBox.shrink();
        // Tooltip é renderizado via OverlayEntry no controller para ficar acima do spotlight.
        return const SizedBox.shrink();
      },
    );
  }
}
