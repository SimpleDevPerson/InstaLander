import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

enum OnboardingMode { app, instagramExport }

class OnboardingScreen extends StatefulWidget {
  final Future<void> Function() onComplete;
  final OnboardingMode mode;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
    this.mode = OnboardingMode.app,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<_OnboardingStep> get _appSteps => [
    _OnboardingStep(
      icon: Icons.lock_outline_rounded,
      eyebrow: context.l10n.onboardingStep1of5,
      title: context.l10n.privateReportTitle,
      description: context.l10n.privateReportDescription,
    ),
    _OnboardingStep(
      icon: Icons.analytics_outlined,
      eyebrow: context.l10n.onboardingStep2of5,
      title: context.l10n.loadReportTitle,
      description: context.l10n.loadReportDescription,
    ),
    _OnboardingStep(
      icon: Icons.favorite_outline_rounded,
      eyebrow: context.l10n.onboardingStep3of5,
      title: context.l10n.chooseWhitelistTitle,
      description: context.l10n.chooseWhitelistDescription,
    ),
    _OnboardingStep(
      icon: Icons.timeline_rounded,
      eyebrow: context.l10n.onboardingStep4of5,
      title: context.l10n.timelineIntroTitle,
      description: context.l10n.timelineIntroDescription,
    ),
    _OnboardingStep(
      icon: Icons.notifications_none_rounded,
      eyebrow: context.l10n.onboardingStep5of5,
      title: context.l10n.reminderIntroTitle,
      description: context.l10n.reminderIntroDescription,
    ),
  ];

  List<_OnboardingStep> get _exportSteps => [
    _OnboardingStep(
      icon: Icons.account_circle_outlined,
      eyebrow: context.l10n.exportStep1of4,
      title: context.l10n.accountsCenterTitle,
      description: context.l10n.accountsCenterDescription,
    ),
    _OnboardingStep(
      icon: Icons.folder_open_outlined,
      eyebrow: context.l10n.exportStep2of4,
      title: context.l10n.requestDataTitle,
      description: context.l10n.requestDataDescription,
    ),
    _OnboardingStep(
      icon: Icons.data_object,
      eyebrow: context.l10n.exportStep3of4,
      title: context.l10n.chooseJsonTitle,
      description: context.l10n.chooseJsonDescription,
    ),
    _OnboardingStep(
      icon: Icons.download_done_outlined,
      eyebrow: context.l10n.exportStep4of4,
      title: context.l10n.downloadArchiveTitle,
      description: context.l10n.downloadArchiveDescription,
    ),
  ];

  List<_OnboardingStep> get _steps =>
      widget.mode == OnboardingMode.instagramExport ? _exportSteps : _appSteps;

  late final PageController _pageController;
  int _currentStep = 0;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _advance() async {
    if (_currentStep == _steps.length - 1) {
      setState(() => _isCompleting = true);
      try {
        await widget.onComplete();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.saveOnboardingError((error).toString()),
              ),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isCompleting = false);
      }
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLastStep = _currentStep == _steps.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'assets/images/app_icon_dark.jpg'
                          : 'assets/images/app_icon_original.png',
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'InstaLander',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentStep + 1}/${_steps.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (_currentStep + 1) / _steps.length,
                borderRadius: BorderRadius.circular(4),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _steps.length,
                  onPageChanged: (index) =>
                      setState(() => _currentStep = index),
                  itemBuilder: (context, index) =>
                      _buildStep(context, _steps[index]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentStep ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentStep
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _isCompleting ? null : _goBack,
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                      ),
                      child: Text(context.l10n.back),
                    )
                  else
                    const SizedBox(width: 80),
                  const Spacer(),
                  FilledButton(
                    onPressed: _isCompleting ? null : _advance,
                    style: FilledButton.styleFrom(
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: _isCompleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isLastStep
                                ? widget.mode == OnboardingMode.instagramExport
                                      ? context.l10n.backToReport
                                      : context.l10n.startApp
                                : context.l10n.next,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, _OnboardingStep step) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                SizedBox(
                  width: 144,
                  height: 144,
                  child: Icon(step.icon, size: 72, color: colorScheme.primary),
                ),
                const SizedBox(height: 32),
                Text(
                  step.eyebrow,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  step.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingStep {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;

  const _OnboardingStep({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
  });
}
