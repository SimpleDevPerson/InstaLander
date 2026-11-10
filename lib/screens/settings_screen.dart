import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Impostazioni'),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme Section
              _buildSectionHeader(context, 'Aspetto', Icons.palette_outlined),
              const SizedBox(height: 8),
              RadioGroup<AppThemeMode>(
                groupValue: themeProvider.appThemeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setAppThemeMode(value);
                  }
                },
                child: Column(
                  children: [
                    _buildThemeOption(
                      context,
                      themeProvider,
                      AppThemeMode.system,
                      'Sistema (Automatico)',
                      'Usa il tema del dispositivo (chiaro/scuro)',
                      Icons.phone_android,
                    ),
                    _buildThemeOption(
                      context,
                      themeProvider,
                      AppThemeMode.samsung,
                      'Samsung One UI',
                      'Tema stile Samsung con angoli arrotondati',
                      Icons.branding_watermark,
                    ),
                    _buildThemeOption(
                      context,
                      themeProvider,
                      AppThemeMode.light,
                      'Chiaro',
                      'Forza il tema chiaro',
                      Icons.light_mode,
                    ),
                    _buildThemeOption(
                      context,
                      themeProvider,
                      AppThemeMode.dark,
                      'Scuro',
                      'Forza il tema scuro',
                      Icons.dark_mode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // About Section
              _buildSectionHeader(context, 'Informazioni', Icons.info_outline),
              const SizedBox(height: 8),
              _buildInfoTile(
                context,
                'Versione',
                '1.0.0',
                Icons.tag,
              ),
              _buildInfoTile(
                context,
                'Progetto',
                'Instagram Follower Checker',
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
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
    AppThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = provider.appThemeMode == mode;
    final themeColor = AppTheme.getPrimaryColor(context, isSamsung: mode == AppThemeMode.samsung);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<AppThemeMode>(
        value: mode,
        title: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? themeColor : Theme.of(context).colorScheme.onSurfaceVariant,
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
        tileColor: isSelected
            ? themeColor.withValues(alpha: 0.05)
            : null,
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