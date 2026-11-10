import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final Future<void> Function() onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _steps = [
    _OnboardingStep(
      icon: Icons.account_circle_outlined,
      eyebrow: 'PASSAGGIO 1 DI 4',
      title: 'Apri il Centro gestione account',
      description:
          'Apri Instagram, vai sul tuo profilo e tocca il menu ≡ in alto. '
          'Entra nel Centro gestione account.',
    ),
    _OnboardingStep(
      icon: Icons.folder_open_outlined,
      eyebrow: 'PASSAGGIO 2 DI 4',
      title: 'Richiedi una copia dei dati',
      description:
          'Apri “Le tue informazioni e autorizzazioni” e scegli “Esporta le '
          'tue informazioni”, poi “Crea esportazione”. Seleziona il tuo '
          'account Instagram.',
    ),
    _OnboardingStep(
      icon: Icons.data_object,
      eyebrow: 'PASSAGGIO 3 DI 4',
      title: 'Scegli il formato JSON',
      description:
          'Seleziona “Esporta sul dispositivo”. Nelle opzioni dell’esportazione '
          'scegli il formato JSON e invia la richiesta. I nomi delle voci '
          'possono variare leggermente in base alla versione di Instagram.',
    ),
    _OnboardingStep(
      icon: Icons.download_done_outlined,
      eyebrow: 'PASSAGGIO 4 DI 4',
      title: 'Scarica ed estrai l’archivio',
      description:
          'Quando Instagram ti avvisa che l’esportazione è pronta, scarica '
          'lo ZIP. Puoi caricare direttamente l’archivio nell’app oppure '
          'estrarlo e selezionare tutti i file followers_*.json e '
          'following_*.json, di solito nella cartella followers_and_following.',
    ),
  ];

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
                content: Text('Impossibile salvare il completamento: $error')),
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
                  const Icon(Icons.camera_alt_outlined,
                      color: AppTheme.instagramGradientMid),
                  const SizedBox(width: 10),
                  Text(
                    'InstaLander',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
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
                      child: const Text('Indietro'),
                    )
                  else
                    const SizedBox(width: 80),
                  const Spacer(),
                  FilledButton(
                    onPressed: _isCompleting ? null : _advance,
                    child: _isCompleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isLastStep ? "Procedi nell'app" : 'Avanti'),
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
                Container(
                  width: 144,
                  height: 144,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primaryContainer,
                  ),
                  child: Icon(
                    step.icon,
                    size: 72,
                    color: colorScheme.onPrimaryContainer,
                  ),
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
