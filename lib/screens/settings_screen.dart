import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Center(
                    child: Text(
                      'Impostazioni',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Theme Section
                      _buildSectionHeader(
                          context, 'Aspetto', Icons.palette_outlined),
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
                      const SizedBox(height: 16),
                      Text(
                        'Luminosità',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Scegli una luminosità fissa oppure segui il dispositivo.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
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
                          foregroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            return states.contains(WidgetState.selected)
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant;
                          }),
                          backgroundColor:
                              WidgetStateProperty.resolveWith((states) {
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
                          context, 'Icona dell’app', Icons.image_outlined),
                      const SizedBox(height: 8),
                      RadioGroup<AppIconStyle>(
                        groupValue: themeProvider.appIconStyle,
                        onChanged: (value) {
                          if (value != null) {
                            unawaited(
                                _changeAppIcon(context, themeProvider, value));
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
                      // About Section
                      _buildSectionHeader(
                          context, 'Informazioni', Icons.info_outline),
                      const SizedBox(height: 8),
                      _buildInfoTile(
                        context,
                        'Versione',
                        '0.3',
                        Icons.tag,
                      ),
                      _buildInfoTile(
                        context,
                        'Progetto',
                        'InstaLander',
                        Icons.code,
                      ),
                      const SizedBox(height: 16),
                      _buildActionTile(
                        context,
                        'Visualizza Whitelist',
                        'Gestisci la lista dei profili ignorati',
                        Icons.favorite_border,
                        () => Navigator.pushNamed(context, '/whitelist'),
                      ),
                      const SizedBox(height: 24),
                      _buildClearDataTile(context),
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
          'Rimuove file importati, whitelist e preferenze salvate',
        ),
        onTap: () => _confirmAndClearData(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
            border: Border.all(
              color: colorScheme.outlineVariant,
              width: 1.5,
            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Future<void> _confirmAndClearData(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancellare tutti i dati?'),
        content: const Text(
          'Verranno eliminati i file importati, la whitelist, i profili '
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
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossibile cancellare i dati: $error')),
      );
    }
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
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
    final themeColor = AppTheme.getPrimaryColor(context,
        isSamsung: mode == AppThemeStyle.samsungOneUi);

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
            ? Icon(
                Icons.check_circle,
                color: themeColor,
                size: 24,
              )
            : null,
        activeColor: themeColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
