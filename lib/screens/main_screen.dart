import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/onboarding_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/whitelist_screen.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/setup_panel.dart';
import '../widgets/stats_counter.dart';
import '../widgets/user_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  // Navbar constants
  static const double navbarHeight = 60;
  static const double navbarBottomMargin = 12;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _navigateToPage(int index) async {
    if (index == _currentIndex) return;
    final pageDistance = (index - _currentIndex).abs();
    setState(() => _currentIndex = index);

    if (pageDistance > 1) {
      _pageController.jumpToPage(index);
      return;
    }

    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _openInstagramProfile(String username) async {
    final url = Uri.parse('https://instagram.com/$username');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.shouldShowOnboarding) {
          return OnboardingScreen(
            onComplete: () async {
              await provider.completeOnboarding();
              if (!provider.hasData && _currentIndex != 0) {
                await _navigateToPage(0);
              }
            },
          );
        }

        final isSamsung = context.watch<ThemeProvider>().isSamsungTheme;
        final bottomSafePadding = MediaQuery.of(context).padding.bottom;

        return PopScope<Object?>(
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && _currentIndex != 0) {
              _navigateToPage(0);
            }
          },
          child: Scaffold(
            backgroundColor: AppTheme.getBgColor(context),
            body: Stack(
              children: [
                _buildPageView(context, provider),
                if (isSamsung)
                  _buildSamsungBottomNavBar(
                    context,
                    bottomSafePadding,
                  ),
              ],
            ),
            bottomNavigationBar:
                isSamsung ? null : _buildMaterialNavigationBar(),
          ),
        );
      },
    );
  }

  Widget _buildPageView(BuildContext context, AppProvider provider) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        if (_currentIndex != index) {
          setState(() => _currentIndex = index);
        }
      },
      children: [
        _buildReportScreen(context, provider),
        const WhitelistScreen(),
        const SettingsScreen(),
      ],
    );
  }

  Widget _buildMaterialNavigationBar() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _navigateToPage,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: 'Report',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: 'Whitelist',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Impostazioni',
        ),
      ],
    );
  }

  Widget _buildSamsungBottomNavBar(
    BuildContext context,
    double bottomSafePadding,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    final totalHeight = navbarHeight + navbarBottomMargin + bottomSafePadding;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: totalHeight,
      child: Center(
        child: SizedBox(
          width: _getSamsungNavbarWidth(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: navbarHeight,
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(navbarHeight / 2),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    width: 0.5,
                  ),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOutCubic,
                      left: _getSamsungIndicatorLeft(context),
                      top: 4,
                      bottom: 4,
                      width: _getIndicatorWidth(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular((navbarHeight - 8) / 2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _buildNavIcon(context, 0, Icons.analytics_outlined,
                            Icons.analytics),
                        _buildNavIcon(
                            context, 1, Icons.favorite_outline, Icons.favorite),
                        _buildNavIcon(context, 2, Icons.settings_outlined,
                            Icons.settings),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: navbarBottomMargin),
              if (bottomSafePadding > 0) SizedBox(height: bottomSafePadding),
            ],
          ),
        ),
      ),
    );
  }

  double _getSamsungNavbarWidth(BuildContext context) {
    final availableWidth = MediaQuery.of(context).size.width - 4;
    return availableWidth.clamp(0.0, 220).toDouble();
  }

  // Helper: Indicator left position - fixed thirds (centers at 1/6, 3/6, 5/6)
  double _getSamsungIndicatorLeft(BuildContext context) {
    final navbarWidth = _getSamsungNavbarWidth(context);
    final indicatorWidth = _getIndicatorWidth(context);
    final centerX = (2 * _currentIndex + 1) * navbarWidth / 6;
    return centerX - (indicatorWidth / 2);
  }

  double _getIndicatorWidth(BuildContext context) => 64;

  // Nav icon: Each item takes 1/3 of navbar width, icon centered in that third
  // Press/highlight area matches the active indicator exactly: 68x52dp pill with 26dp radius
  Widget _buildNavIcon(
    BuildContext context,
    int index,
    IconData icon,
    IconData selectedIcon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _currentIndex == index;

    // Keep each tap target aligned with the slimmer active indicator.
    const double indicatorWidth = 64;
    const double indicatorHeight = navbarHeight - 8; // 52
    const double indicatorRadius = indicatorHeight / 2; // 26

    return Expanded(
      child: Center(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(indicatorRadius),
          child: InkWell(
            splashFactory: NoSplash.splashFactory,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            onTap: () => _navigateToPage(index),
            borderRadius: BorderRadius.circular(indicatorRadius),
            // Constrain the tap/highlight area to exactly match the indicator
            child: SizedBox(
              width: indicatorWidth,
              height: indicatorHeight,
              child: Center(
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ... rest of the existing methods (unchanged)
  Widget _buildReportScreen(BuildContext context, AppProvider provider) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(context, provider),
          Expanded(child: _buildContent(context, provider)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildInstagramLogo(),
          const SizedBox(width: 12),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  children: provider.hasData
                      ? const [
                          TextSpan(text: 'Il tuo '),
                          TextSpan(
                            text: 'unfollower',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: ' report'),
                        ]
                      : const [TextSpan(text: 'Instalander')],
                ),
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: 34, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstagramLogo() {
    return ShaderMask(
      shaderCallback: AppTheme.instagramGradient.createShader,
      blendMode: BlendMode.srcIn,
      child: SizedBox(
        width: 44,
        height: 44,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 19,
                height: 19,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return _buildErrorState(context, provider);
    }
    if (provider.hasPartialData) {
      return _buildMissingFileState(context, provider);
    }
    if (!provider.hasData) {
      return _buildSetupState(context, provider);
    }
    return _buildMainContent(context, provider);
  }

  Widget _buildErrorState(BuildContext context, AppProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: AppTheme.instagramRed),
            const SizedBox(height: 16),
            Text('Errore', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getSubTextColor(context),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: () => provider.initialize(),
                child: const Text('Riprova')),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupState(BuildContext context, AppProvider provider) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          SetupPanel(onShowGuide: () => _openOnboarding(context, provider)),
          const SizedBox(height: 24),
          _buildUploadButton(context, provider),
          const SizedBox(height: 10),
          _buildArchiveUploadButton(provider),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMissingFileState(
    BuildContext context,
    AppProvider provider,
  ) {
    final missingFollowers = !provider.hasFollowersFile;
    final missingLabel = missingFollowers ? 'dei follower' : 'dei seguiti';
    final missingFileName =
        missingFollowers ? 'followers_*.json' : 'following_*.json';
    final icon = missingFollowers
        ? Icons.people_alt_outlined
        : Icons.person_add_alt_1_outlined;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Manca un file',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Abbiamo rilevato il file ${missingFollowers ? 'dei seguiti' : 'dei follower'}. '
              'Per creare il report, carica anche il file $missingLabel '
              '($missingFileName).',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.getSubTextColor(context),
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 220,
              height: 190,
              child: FilledButton(
                onPressed: () => _pickAndLoadFiles(provider),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.all(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file_outlined, size: 64),
                    const SizedBox(height: 12),
                    Text(
                      'Carica file\n$missingLabel',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _pickAndLoadArchive(provider),
              icon: const Icon(Icons.folder_zip_outlined),
              label: const Text('Oppure carica un archivio ZIP'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, AppProvider provider) {
    return OutlinedButton.icon(
      onPressed: () => _pickAndLoadFiles(provider),
      icon: const Icon(Icons.cloud_upload_outlined, size: 20),
      label: const Text('Carica JSON'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    );
  }

  Widget _buildArchiveUploadButton(AppProvider provider) {
    return OutlinedButton.icon(
      onPressed: () => _pickAndLoadArchive(provider),
      icon: const Icon(Icons.folder_zip_outlined, size: 20),
      label: const Text('Carica archivio ZIP'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Future<void> _openOnboarding(
    BuildContext context,
    AppProvider provider,
  ) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(
          onComplete: () async {
            await provider.completeOnboarding();
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, AppProvider provider) {
    final users = provider.sortedNonFollowers;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: StatsCounter(count: provider.stats['visibleCount'] ?? 0),
        ),
        SliverToBoxAdapter(child: _buildControls(context, provider)),
        if (users.isNotEmpty)
          _buildUserList(context, provider, users)
        else
          SliverToBoxAdapter(child: _buildEmptyState(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildControls(BuildContext context, AppProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 56,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.72),
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PopupMenuButton<SortOption>(
                  onSelected: provider.setSortOption,
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 4),
                  color: colorScheme.surfaceContainerHighest,
                  elevation: 8,
                  constraints: const BoxConstraints(
                    minWidth: 240,
                    maxWidth: 240,
                  ),
                  menuPadding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  itemBuilder: (context) => SortOption.values.map((option) {
                    final title = switch (option) {
                      SortOption.dateDesc => 'Data decrescente',
                      SortOption.dateAsc => 'Data crescente',
                      SortOption.alphaAsc => 'Alfabetico (A-Z)',
                      SortOption.alphaDesc => 'Alfabetico (Z-A)',
                    };
                    final subtitle = switch (option) {
                      SortOption.dateDesc => '(Più recenti prima)',
                      SortOption.dateAsc => '(Più vecchi prima)',
                      SortOption.alphaAsc || SortOption.alphaDesc => '',
                    };
                    final directionIcon = switch (option) {
                      SortOption.dateDesc ||
                      SortOption.alphaAsc =>
                        Icons.arrow_downward,
                      SortOption.dateAsc ||
                      SortOption.alphaDesc =>
                        Icons.arrow_upward,
                    };
                    final isSelected = option == provider.currentSort;

                    return PopupMenuItem(
                      value: option,
                      height: 56,
                      padding: EdgeInsets.zero,
                      child: SizedBox(
                        height: 56,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.onSurface.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              if (option == SortOption.dateDesc ||
                                  option == SortOption.dateAsc)
                                Icon(
                                  Icons.calendar_month_outlined,
                                  size: 26,
                                  color: colorScheme.onSurfaceVariant,
                                )
                              else
                                Text(
                                  option == SortOption.alphaAsc
                                      ? 'A\nZ'
                                      : 'Z\nA',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    height: 0.85,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              const SizedBox(width: 4),
                              Icon(
                                directionIcon,
                                size: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface,
                                          ),
                                    ),
                                    if (subtitle.isNotEmpty)
                                      Text(
                                        subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontSize: 12,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: Color(0xFF4CAF50),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          switch (provider.currentSort) {
                            SortOption.dateDesc => 'Più recenti',
                            SortOption.dateAsc => 'Più vecchi',
                            SortOption.alphaAsc => 'Nome A-Z',
                            SortOption.alphaDesc => 'Nome Z-A',
                          },
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickAndLoadFiles(provider),
              icon: const Icon(Icons.cloud_upload_outlined, size: 22),
              label: const Text('JSON'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 54),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(color: colorScheme.outlineVariant),
                backgroundColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickAndLoadArchive(provider),
              icon: const Icon(Icons.folder_zip_outlined, size: 22),
              label: const Text('ZIP'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 54),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(color: colorScheme.outlineVariant),
                backgroundColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndLoadFiles(AppProvider provider) async {
    try {
      final files = await DataService.pickJsonFiles();
      if (files != null && files.isNotEmpty) {
        await provider.loadJsonFiles(files);
      }
    } catch (e) {
      provider.setError('Errore selezione file: $e');
    }
  }

  Future<void> _pickAndLoadArchive(AppProvider provider) async {
    try {
      final archive = await DataService.pickInstagramArchive();
      if (archive != null) {
        await provider.loadInstagramArchive(archive);
      }
    } catch (e) {
      provider.setError('Errore selezione archivio ZIP: $e');
    }
  }

  Widget _buildUserList(
    BuildContext context,
    AppProvider provider,
    List<InstagramUser> users,
  ) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            (constraints.crossAxisExtent / 180).floor().clamp(2, 4);
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final user = users[index];
                return UserCard(
                  user: user,
                  isViewed: provider.isProfileViewed(user.username),
                  onTap: () async {
                    await provider.markProfileViewed(user.username);
                    await _openInstagramProfile(user.username);
                  },
                  onWhitelist: () => provider.addToWhitelist(user.username),
                );
              },
              childCount: users.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline,
                size: 80, color: AppTheme.getSubTextColor(context)),
            const SizedBox(height: 16),
            Text(
              'Tutti ricambiano il follow! 🎉',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.getSubTextColor(context),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Non ci sono profili da controllare.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getSubTextColor(context),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
