import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../services/ads_service.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';
import '../widgets/one_ui_brightness_selector.dart';
import '../widgets/reminder_interval_selector.dart';
import '../widgets/settings_toggle_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBgColor(context),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.settings_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Impostazioni',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      themeProvider.isSamsungTheme ? 100 : 16,
                    ),
                    children: [
                      // Theme Section
                      _buildSectionHeader(
                        context,
                        'Aspetto',
                        Icons.palette_outlined,
                      ),
                      const SizedBox(height: 8),
                      RadioGroup<AppThemeStyle>(
                        groupValue: themeProvider.themeStyle,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setThemeStyle(value);
                          }
                        },
                        child: Column(
                          children: [
                            _buildThemeOption(
                              context,
                              themeProvider,
                              AppThemeStyle.materialExpressive,
                              AppThemeStyle.materialExpressive.label,
                              'Layout e componenti Material 3',
                              Icons.widgets_outlined,
                            ),
                            _buildThemeOption(
                              context,
                              themeProvider,
                              AppThemeStyle.samsungOneUi,
                              AppThemeStyle.samsungOneUi.label,
                              'Interfaccia One UI con navigazione a pillola',
                              Icons.branding_watermark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        context,
                        'Luminosità',
                        Icons.brightness_6_outlined,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Scegli una luminosità fissa oppure segui il dispositivo.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (themeProvider.isSamsungTheme)
                        OneUiBrightnessSelector(
                          value: themeProvider.brightnessMode,
                          onChanged: themeProvider.setBrightnessMode,
                        )
                      else
                        SegmentedButton<AppBrightnessMode>(
                          segments: [
                            for (final mode in AppBrightnessMode.values)
                              ButtonSegment(
                                value: mode,
                                icon: Icon(mode.icon),
                                label: Text(switch (mode) {
                                  AppBrightnessMode.system => 'Sistema',
                                  AppBrightnessMode.light => 'Chiaro',
                                  AppBrightnessMode.dark => 'Scuro',
                                }),
                              ),
                          ],
                          selected: {themeProvider.brightnessMode},
                          onSelectionChanged: (selection) {
                            themeProvider.setBrightnessMode(selection.first);
                          },
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              return states.contains(WidgetState.selected)
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant;
                            }),
                            backgroundColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              return states.contains(WidgetState.selected)
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent;
                            }),
                            side: WidgetStateProperty.resolveWith((states) {
                              return BorderSide(
                                color: states.contains(WidgetState.selected)
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                              );
                            }),
                          ),
                          showSelectedIcon: false,
                        ),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        context,
                        'Icona dell’app',
                        Icons.image_outlined,
                      ),
                      const SizedBox(height: 8),
                      RadioGroup<AppIconStyle>(
                        groupValue: themeProvider.appIconStyle,
                        onChanged: (value) {
                          if (value != null) {
                            unawaited(
                              _changeAppIcon(context, themeProvider, value),
                            );
                          }
                        },
                        child: Column(
                          children: [
                            _buildAppIconOption(
                              context,
                              themeProvider,
                              AppIconStyle.original,
                              'Icona chiara',
                              'Icona originale con sfondo chiaro',
                              'assets/images/app_icon_original.png',
                            ),
                            _buildAppIconOption(
                              context,
                              themeProvider,
                              AppIconStyle.dark,
                              'Icona scura',
                              'Variante con sfondo scuro',
                              'assets/images/app_icon_dark.jpg',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        context,
                        'Promemoria',
                        Icons.notifications_outlined,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Consumer<AppProvider>(
                          builder: (context, app, _) => Column(
                            children: [
                              SettingsToggleTile(
                                title: 'Promemoria Instagram',
                                isSamsung: themeProvider.isSamsungTheme,
                                subtitle: ReminderService.supported
                                    ? 'Ricorda di richiedere il download delle tue informazioni. Notifica locale, senza mantenere l’app attiva.'
                                    : 'Disponibile nell’app Android.',
                                value: app.monthlyReminder,
                                onChanged: ReminderService.supported
                                    ? (enabled) async {
                                        try {
                                          final saved = await app
                                              .setMonthlyReminder(enabled);
                                          if (!saved && context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Consenti le notifiche nelle impostazioni di sistema per attivare il promemoria.',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (error) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Impossibile impostare il promemoria: $error',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: ReminderIntervalSelector(
                                  key: const ValueKey('reminder-frequency'),
                                  value: app.reminderIntervalMonths,
                                  isSamsung: themeProvider.isSamsungTheme,
                                  onChanged: ReminderService.supported
                                      ? (months) async {
                                          try {
                                            await app.setReminderIntervalMonths(
                                              months,
                                            );
                                          } catch (error) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Impossibile salvare la frequenza: $error',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // About Section
                      _buildSectionHeader(
                        context,
                        'Informazioni',
                        Icons.info_outline,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoTile(context, 'Versione', '0.5.0', Icons.tag),
                      _buildActionTile(
                        context,
                        'Progetto',
                        'InstaLander',
                        Icons.code,
                        () => unawaited(_openProject(context)),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable:
                            AdsService.instance.privacyOptionsRequired,
                        builder: (context, isRequired, child) {
                          if (!isRequired) return const SizedBox.shrink();
                          return _buildActionTile(
                            context,
                            'Privacy pubblicitaria',
                            'Gestisci le preferenze di consenso',
                            Icons.privacy_tip_outlined,
                            AdsService.instance.showPrivacyOptions,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildDebugSection(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openProject(BuildContext context) async {
    try {
      final opened = await launchUrl(
        Uri.parse('https://github.com/SimpleDevPerson/InstaLander'),
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    } catch (_) {
      // Report both launch failures and unavailable URL handlers below.
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossibile aprire la repository')),
    );
  }

  Widget _buildDebugSection(BuildContext context) {
    final app = context.read<AppProvider>();
    void populate(VoidCallback action, String section) {
      action();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Dati di prova aggiunti: $section')),
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(context, 'Debug', Icons.bug_report_outlined),
        const SizedBox(height: 8),
        const Text(
          'Genera profili casuali con prefisso debug_. I dati di prova sono temporanei: scompaiono al riavvio o quando importi nuovi JSON. I dati importati restano conservati.',
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          'Popola timeline',
          'Aggiungi intervalli e unfollow di prova',
          Icons.timeline,
          () => populate(app.populateDebugTimeline, 'timeline'),
          showChevron: false,
        ),
        _buildActionTile(
          context,
          'Popola whitelist',
          'Aggiungi profili di prova alla whitelist',
          Icons.favorite_outline,
          () => populate(app.populateDebugWhitelist, 'whitelist'),
          showChevron: false,
        ),
        _buildActionTile(
          context,
          'Popola report',
          'Genera follower e seguiti di prova',
          Icons.analytics_outlined,
          () => populate(app.populateDebugReport, 'report'),
          showChevron: false,
        ),
        const SizedBox(height: 24),
        _buildClearDataTile(context),
      ],
    );
  }

  Widget _buildClearDataTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.error.withValues(alpha: 0.55),
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: Icon(Icons.delete_outline, color: colorScheme.error),
        title: Text(
          'Cancella tutti i dati',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Text(
          'Rimuove file importati, timeline, whitelist, promemoria e preferenze',
        ),
        onTap: () => _confirmAndClearData(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _changeAppIcon(
    BuildContext context,
    ThemeProvider provider,
    AppIconStyle style,
  ) async {
    try {
      await provider.setAppIconStyle(style);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossibile cambiare icona: $error')),
      );
    }
  }

  Widget _buildAppIconOption(
    BuildContext context,
    ThemeProvider provider,
    AppIconStyle style,
    String title,
    String subtitle,
    String iconAsset,
  ) {
    final isSelected = provider.appIconStyle == style;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<AppIconStyle>(
        value: style,
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? colorScheme.primary : null,
          ),
        ),
        subtitle: Text(subtitle),
        secondary: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                iconAsset,
                width: 53,
                height: 53,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.broken_image_outlined,
                    size: 40,
                    color: colorScheme.error,
                  );
                },
              ),
            ),
          ),
        ),
        activeColor: colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _confirmAndClearData(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancellare tutti i dati?'),
        content: const Text(
          'Verranno eliminati i file importati, la timeline, il promemoria, la whitelist, i profili '
          'controllati e le preferenze. L’operazione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Colors.black,
            ),
            child: const Text('Cancella tutto'),
          ),
        ],
      ),
    );

    if (shouldClear != true || !context.mounted) return;

    final appProvider = context.read<AppProvider>();
    final themeProvider = context.read<ThemeProvider>();
    try {
      await appProvider.clearAllData();
      await themeProvider.resetToDefaults();
      await AdsService.instance.setAdsEnabled(false);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossibile cancellare i dati: $error')),
      );
    }
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider provider,
    AppThemeStyle mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = provider.themeStyle == mode;
    final themeColor = AppTheme.getPrimaryColor(
      context,
      isSamsung: mode == AppThemeStyle.samsungOneUi,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<AppThemeStyle>(
        value: mode,
        title: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? themeColor
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? themeColor : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        secondary: isSelected
            ? Icon(Icons.check_circle, color: themeColor, size: 24)
            : null,
        activeColor: themeColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: isSelected ? themeColor.withValues(alpha: 0.05) : null,
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool showChevron = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: showChevron
            ? Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
