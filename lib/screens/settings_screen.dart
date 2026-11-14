import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_strings.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../services/ads_service.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';
import '../widgets/debug_notification_dialog.dart';
import '../widgets/language_selector.dart';
import '../widgets/one_ui_brightness_selector.dart';
import '../widgets/reminder_interval_selector.dart';
import '../widgets/settings_toggle_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _versionTapCount = 0;
  bool _unlockingDebug = false;
  ValueNotifier<String>? _developerNotice;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _developerSnackBar;
  Timer? _developerNoticeTimer;

  void _showDeveloperNotice(String message) {
    final notice = _developerNotice;
    if (notice != null) {
      notice.value = message;
    } else {
      final newNotice = ValueNotifier(message);
      _developerNotice = newNotice;
      final messenger = ScaffoldMessenger.of(context);
      messenger.removeCurrentSnackBar();
      final controller = messenger.showSnackBar(
        SnackBar(
          // A resettable timer below controls dismissal after the last tap.
          duration: const Duration(days: 1),
          content: ValueListenableBuilder<String>(
            valueListenable: newNotice,
            builder: (_, text, _) => Text(text),
          ),
        ),
      );
      _developerSnackBar = controller;
      unawaited(
        controller.closed.then((_) {
          newNotice.dispose();
          if (identical(_developerNotice, newNotice)) {
            _developerNotice = null;
            _developerSnackBar = null;
          }
        }),
      );
    }
    _developerNoticeTimer?.cancel();
    _developerNoticeTimer = Timer(const Duration(seconds: 3), () {
      final controller = _developerSnackBar;
      _developerNotice = null;
      _developerSnackBar = null;
      controller?.close();
    });
  }

  @override
  void dispose() {
    _developerNoticeTimer?.cancel();
    _developerSnackBar?.close();
    super.dispose();
  }

  Future<void> _onVersionTap() async {
    final app = context.read<AppProvider>();
    if (app.debugToolsEnabled || _unlockingDebug) return;
    _versionTapCount++;
    final remaining = 10 - _versionTapCount;
    String message;
    if (remaining > 0) {
      if (remaining > 5) return;
      message = remaining == 1
          ? context.l10n.oneTapToDeveloper
          : context.l10n.tapsToDeveloper((remaining).toString());
    } else {
      _unlockingDebug = true;
      _showDeveloperNotice(context.l10n.enablingDeveloper);
      try {
        await app.enableDebugTools();
        if (!mounted) return;
        message = context.l10n.developerEnabled;
      } catch (_) {
        if (!mounted) return;
        _versionTapCount = 9;
        message = context.l10n.developerEnableError;
      } finally {
        _unlockingDebug = false;
      }
    }
    if (!mounted) return;
    _showDeveloperNotice(message);
  }

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
                  height: 66,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                          context.l10n.settings,
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
                        context.l10n.appearance,
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
                              context.l10n.materialThemeDescription,
                              Icons.widgets_outlined,
                            ),
                            _buildThemeOption(
                              context,
                              themeProvider,
                              AppThemeStyle.samsungOneUi,
                              AppThemeStyle.samsungOneUi.label,
                              context.l10n.oneUiThemeDescription,
                              Icons.branding_watermark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        context,
                        context.l10n.brightness,
                        Icons.brightness_6_outlined,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.brightnessDescription,
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
                                  AppBrightnessMode.system =>
                                    context.l10n.system,
                                  AppBrightnessMode.light => context.l10n.light,
                                  AppBrightnessMode.dark => context.l10n.dark,
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
                        context.l10n.appIcon,
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
                              context.l10n.lightIcon,
                              context.l10n.lightIconDescription,
                              'assets/images/app_icon_original.png',
                            ),
                            _buildAppIconOption(
                              context,
                              themeProvider,
                              AppIconStyle.dark,
                              context.l10n.darkIconTitle,
                              context.l10n.darkIconDescription,
                              'assets/images/app_icon_dark.jpg',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildLanguageSection(context, themeProvider),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        context,
                        context.l10n.behavior,
                        Icons.tune_rounded,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Consumer<AppProvider>(
                          builder: (context, app, _) => SettingsToggleTile(
                            title: context.l10n.openProfilesInBrowser,
                            subtitle: app.openProfilesInBrowser
                                ? context.l10n.openBrowserDescription
                                : context.l10n.openInstagramDescription,
                            value: app.openProfilesInBrowser,
                            isSamsung: themeProvider.isSamsungTheme,
                            onChanged: (value) async {
                              try {
                                await app.setOpenProfilesInBrowser(value);
                              } catch (_) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.l10n.savePreferenceError,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Consumer<AppProvider>(
                          builder: (context, app, _) => SettingsToggleTile(
                            title: context.l10n.autoWhitelist,
                            subtitle: context.l10n.autoWhitelistDescription,
                            value: app.autoWhitelistOnImport,
                            isSamsung: themeProvider.isSamsungTheme,
                            onChanged: (value) async {
                              try {
                                await app.setAutoWhitelistOnImport(value);
                              } catch (_) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.l10n.savePreferenceError,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        context,
                        context.l10n.reminders,
                        Icons.notifications_outlined,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Consumer<AppProvider>(
                          builder: (context, app, _) => Column(
                            children: [
                              SettingsToggleTile(
                                title: context.l10n.instagramReminder,
                                isSamsung: themeProvider.isSamsungTheme,
                                subtitle: ReminderService.supported
                                    ? context.l10n.reminderDescription
                                    : context.l10n.androidOnly,
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
                                              SnackBar(
                                                content: Text(
                                                  context
                                                      .l10n
                                                      .allowReminderNotifications,
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
                                                context.l10n.setReminderError(
                                                  (error).toString(),
                                                ),
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
                                                  context.l10n
                                                      .saveReminderFrequencyError(
                                                        (error).toString(),
                                                      ),
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
                        context.l10n.about,
                        Icons.info_outline,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoTile(
                        context,
                        context.l10n.version,
                        '0.7.0',
                        Icons.tag,
                        onTap: _onVersionTap,
                      ),
                      _buildActionTile(
                        context,
                        context.l10n.project,
                        'InstaLander',
                        Icons.code,
                        () => unawaited(_openProject(context)),
                      ),
                      _buildActionTile(
                        context,
                        context.l10n.advertisingPrivacy,
                        context.l10n.manageConsent,
                        Icons.privacy_tip_outlined,
                        () async {
                          if (AdsService
                              .instance
                              .privacyOptionsRequired
                              .value) {
                            await AdsService.instance.showPrivacyOptions();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.noConsentOptions),
                              ),
                            );
                          }
                        },
                      ),
                      if (context.watch<AppProvider>().debugToolsEnabled) ...[
                        const SizedBox(height: 24),
                        _buildDebugSection(context),
                      ],
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

  Widget _buildLanguageSection(BuildContext context, ThemeProvider provider) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(
            context,
            context.l10n.language,
            Icons.language_rounded,
          ),
          const SizedBox(height: 8),
          LanguageSelector(
            value: provider.languageCode,
            onChanged: (code) async {
              try {
                await provider.setLanguage(code);
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.savePreferenceError)),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(context.l10n.languageDescription),
          ),
        ],
      );

  Future<void> _hideDebugOptions() async {
    try {
      await context.read<AppProvider>().hideDebugTools();
      if (!mounted) return;
      setState(() => _versionTapCount = 0);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.debugHidden)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.savePreferenceError)));
    }
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.cannotOpenRepository)));
  }

  Future<void> _testNotification({bool scheduled = false}) async {
    Duration? delay;
    if (scheduled) {
      delay = await showDialog<Duration>(
        context: context,
        builder: (_) => const DebugNotificationDialog(),
      );
      if (delay == null || !mounted) return;
    }
    String message;
    try {
      final sent = scheduled
          ? await ReminderService.scheduleDebugNotification(delay!)
          : await ReminderService.showDebugNotification();
      if (!mounted) return;
      message = sent
          ? (scheduled
                ? context.l10n.testNotificationScheduled
                : context.l10n.testNotificationSent)
          : context.l10n.allowTestNotifications;
    } catch (_) {
      if (!mounted) return;
      message = context.l10n.testNotificationError;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildDebugSection(BuildContext context) {
    final app = context.read<AppProvider>();
    void populate(VoidCallback action, String section) {
      action();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.l10n.testDataAdded((section).toString())),
          ),
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(context, 'Debug', Icons.bug_report_outlined),
        const SizedBox(height: 8),
        _buildInfoTile(
          context,
          context.l10n.buildMode,
          kDebugMode ? 'Debug' : (kProfileMode ? 'Profile' : 'Release'),
          kDebugMode ? Icons.bug_report_outlined : Icons.verified_outlined,
        ),
        Text(context.l10n.debugDataDescription),
        const SizedBox(height: 12),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ValueListenableBuilder<bool>(
            valueListenable: AdsService.instance.adsEnabled,
            builder: (context, enabled, _) => SettingsToggleTile(
              title: context.l10n.advertising,
              subtitle: context.l10n.advertisingDescription,
              value: enabled,
              isSamsung: context.watch<ThemeProvider>().isSamsungTheme,
              onChanged: (value) async {
                try {
                  await AdsService.instance.setAdsEnabled(value);
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.savePreferenceError)),
                  );
                }
              },
            ),
          ),
        ),
        _buildActionTile(
          context,
          context.l10n.populateTimeline,
          context.l10n.populateTimelineDescription,
          Icons.timeline,
          () => populate(app.populateDebugTimeline, 'timeline'),
          showChevron: false,
        ),
        _buildActionTile(
          context,
          context.l10n.populateWhitelist,
          context.l10n.populateWhitelistDescription,
          Icons.favorite_outline,
          () => populate(app.populateDebugWhitelist, 'whitelist'),
          showChevron: false,
        ),
        _buildActionTile(
          context,
          context.l10n.populateReport,
          context.l10n.populateReportDescription,
          Icons.analytics_outlined,
          () => populate(app.populateDebugReport, 'report'),
          showChevron: false,
        ),
        const SizedBox(height: 24),
        _buildActionTile(
          context,
          context.l10n.sendTestNotification,
          context.l10n.sendTestNotificationDescription,
          Icons.notifications_active_outlined,
          () => _testNotification(),
          showChevron: false,
        ),
        _buildActionTile(
          context,
          context.l10n.scheduleTestNotification,
          context.l10n.scheduleTestNotificationDescription,
          Icons.notification_add_outlined,
          () => _testNotification(scheduled: true),
        ),
        const SizedBox(height: 24),
        _buildActionTile(
          context,
          context.l10n.hideDebug,
          context.l10n.hideDebugDescription,
          Icons.visibility_off_outlined,
          _hideDebugOptions,
          showChevron: false,
        ),
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
          context.l10n.clearAllData,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(context.l10n.clearAllDataDescription),
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
        SnackBar(
          content: Text(context.l10n.changeIconError((error).toString())),
        ),
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
        title: Text(context.l10n.clearAllDataTitle),
        content: Text(context.l10n.clearAllDataConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            child: Text(context.l10n.clearEverything),
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
        SnackBar(
          content: Text(context.l10n.clearAllDataError((error).toString())),
        ),
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
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
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
