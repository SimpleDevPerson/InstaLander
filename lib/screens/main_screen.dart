import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
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
  int _programmaticNavigationRequest = 0;
  late final PageController _pageController;

  // Navbar constants
  static const double navbarHeight = 60;
  static const double navbarHorizontalMargin = 6;
  static const double navbarMaxWidth = 260;
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
    final request = ++_programmaticNavigationRequest;
    setState(() => _currentIndex = index);

    try {
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } finally {
      if (request == _programmaticNavigationRequest) {
        _programmaticNavigationRequest = 0;
      }
    }
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
        final bottomSafePadding = MediaQuery.of(context).padding.bottom;

        return Scaffold(
          backgroundColor: AppTheme.getBgColor(context),
          // No bottomNavigationBar - we use Stack with Positioned navbar overlay
          body: Stack(
            children: [
              // PageView fills ENTIRE screen - content scrolls under navbar
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  if (_programmaticNavigationRequest == 0) {
                    setState(() => _currentIndex = index);
                  }
                },
                children: [
                  _buildReportScreen(context, provider),
                  const WhitelistScreen(),
                  const SettingsScreen(),
                ],
              ),
              // Floating navbar overlay at bottom - covers content
              _buildBottomNavBar(context, provider, bottomSafePadding),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar(
      BuildContext context, AppProvider provider, double bottomSafePadding) {
    final isSamsung = context.watch<ThemeProvider>().isSamsungTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Samsung theme: Floating pill navbar
    if (isSamsung) {
      // Total navbar area height = pill + bottom margin + safe area
      final totalHeight = navbarHeight + navbarBottomMargin + bottomSafePadding;

      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        height: totalHeight,
        child: Center(
          child: SizedBox(
            width: _getNavbarWidth(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Main navbar pill - semi-transparent so content behind is visible
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
                        left: _getIndicatorLeft(context),
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
                          _buildNavIcon(context, 1, Icons.favorite_outline,
                              Icons.favorite),
                          _buildNavIcon(context, 2, Icons.settings_outlined,
                              Icons.settings),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bottom margin spacer
                const SizedBox(height: navbarBottomMargin),
                // Safe area spacer
                if (bottomSafePadding > 0) SizedBox(height: bottomSafePadding),
              ],
            ),
          ),
        ),
      );
    }

    // Non-Samsung theme: Standard NavigationBar at bottom
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomSafePadding,
      child: Center(
        child: SizedBox(
          width: _getNavbarWidth(context),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _navigateToPage,
            height: 72,
            indicatorColor: colorScheme.primaryContainer,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics, color: Colors.white),
                label: 'Report',
              ),
              NavigationDestination(
                icon: Badge(
                    isLabelVisible: false, child: Icon(Icons.favorite_outline)),
                selectedIcon: Badge(
                    isLabelVisible: false,
                    child: Icon(Icons.favorite, color: Colors.white)),
                label: 'Whitelist',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings, color: Colors.white),
                label: 'Impostazioni',
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getNavbarWidth(BuildContext context) {
    final availableWidth =
        MediaQuery.of(context).size.width - navbarHorizontalMargin * 2;
    return availableWidth.clamp(0.0, navbarMaxWidth).toDouble();
  }

  // Helper: Indicator left position - fixed thirds (centers at 1/6, 3/6, 5/6)
  double _getIndicatorLeft(BuildContext context) {
    final navbarWidth = _getNavbarWidth(context);
    final indicatorWidth = _getIndicatorWidth(context);
    final centerX = (2 * _currentIndex + 1) * navbarWidth / 6;
    return centerX - (indicatorWidth / 2);
  }

  double _getIndicatorWidth(BuildContext context) => 68;

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

    // Indicator dimensions: 68 wide, 52 tall (navbarHeight - 8), 26 radius
    const double indicatorWidth = 68;
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
                  color:
                      isSelected ? Colors.white : colorScheme.onSurfaceVariant,
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
    final isSamsung = context.watch<ThemeProvider>().isSamsungTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.getCardBg(context),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: isSamsung ? 0.5 : 1,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInstagramLogo(),
          const SizedBox(width: 12),
          Text(
            'Unfollower Report',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildInstagramLogo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoColor = isDark ? Colors.white : Colors.black;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: logoColor, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: logoColor, width: 2),
            ),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: 4,
              height: 4,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: logoColor),
            ),
          ),
        ],
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
          const SetupPanel(),
          const SizedBox(height: 24),
          const StatsCounter(count: 0),
          const SizedBox(height: 24),
          _buildUploadButton(context, provider),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, AppProvider provider) {
    return OutlinedButton.icon(
      onPressed: () => _pickAndLoadFiles(provider),
      icon: const Icon(Icons.cloud_upload_outlined, size: 20),
      label: const Text('Carica JSON'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.getCardBg(context),
                border: Border.all(color: AppTheme.getBorderColor(context)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<SortOption>(
                  value: provider.currentSort,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: AppTheme.getSubTextColor(context)),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.getTextColor(context),
                      ),
                  dropdownColor: AppTheme.getCardBg(context),
                  borderRadius: BorderRadius.circular(8),
                  items: SortOption.values.map((option) {
                    return DropdownMenuItem(
                        value: option, child: Text(option.label));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) provider.setSortOption(value);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickAndLoadFiles(provider),
              icon: const Icon(Icons.cloud_upload_outlined, size: 20),
              label: const Text('Carica JSON'),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12)),
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
              childAspectRatio: 0.75,
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
