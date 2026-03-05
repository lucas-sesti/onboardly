import 'package:flutter/material.dart';

class OnboardingSkipSheet extends StatelessWidget {
  const OnboardingSkipSheet({
    super.key,
    this.title,
    this.continueButtonText,
    this.skipButtonText,
    this.titleWidget,
    this.continueButtonWidget,
    this.skipButtonWidget,
  });

  final String? title;
  final String? continueButtonText;
  final String? skipButtonText;
  final Widget? titleWidget;
  final Widget? continueButtonWidget;
  final Widget? skipButtonWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          titleWidget ??
              Text(
                title ?? 'Are you sure you want to skip the tutorial?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
          SizedBox(height: 24),
          continueButtonWidget ??
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    continueButtonText ?? 'Continue tutorial',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          SizedBox(height: 12),
          skipButtonWidget ??
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    skipButtonText ?? 'Skip tutorial',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
