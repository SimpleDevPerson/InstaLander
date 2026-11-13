import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/stats_counter.dart';

enum _WhitelistView { list, grid }

class WhitelistScreen extends StatefulWidget {
  const WhitelistScreen({super.key});

  @override
  State<WhitelistScreen> createState() => _WhitelistScreenState();
}

class _WhitelistScreenState extends State<WhitelistScreen> {
  static const _avatarBlues = [
    Color(0xFF1565C0),
    Color(0xFF1976D2),
    Color(0xFF1E88E5),
    Color(0xFF0288D1),
    Color(0xFF039BE5),
    Color(0xFF3949AB),
    Color(0xFF3F51B5),
    Color(0xFF00838F),
  ];

  _WhitelistView _view = _WhitelistView.list;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _avatarColor(String username) {
    final usernameHash = username.codeUnits.fold<int>(
      0,
      (hash, codeUnit) => hash * 31 + codeUnit,
    );
    return _avatarBlues[usernameHash.abs() % _avatarBlues.length];
  }

  Widget _buildWhitelistAvatar(String username, {required double radius}) {
    final avatarColor = _avatarColor(username);
    return Container(
      key: ValueKey('whitelist-avatar-$username'),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: avatarColor.withValues(alpha: 0.32),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: avatarColor,
        foregroundColor: Colors.white,
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: radius * 0.72,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildFramedActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: color,
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final whitelist = provider.whitelist.toList();
        _sortWhitelist(whitelist, provider.currentSort);
        final normalizedQuery = _searchQuery
            .trim()
            .replaceFirst(
              RegExp(r'^@'),
              '',
            )
            .toLowerCase();
        final filteredWhitelist = normalizedQuery.isEmpty
            ? whitelist
            : whitelist
                .where((username) =>
                    username.toLowerCase().contains(normalizedQuery))
                .toList();

        return Scaffold(
          backgroundColor: AppTheme.getBgColor(context),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                  child: SizedBox(
                    height: 54,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Theme.of(context).colorScheme.primary,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Whitelist',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                StatsCounter(
                  count: whitelist.length,
                  label: 'Profili in whitelist:',
                  semanticsLabel: 'Profili in whitelist',
                  indicatorIcon: Icons.favorite,
                ),
                if (whitelist.isNotEmpty) ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: _buildViewSelector(context)),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildSortSelector(context, provider),
                        ),
                        const SizedBox(width: 8),
                        _buildClearButton(context, provider),
                      ],
                    ),
                  ),
                  _buildSearchField(context),
                ],
                Expanded(
                  child: whitelist.isEmpty
                      ? _buildEmptyState(context)
                      : filteredWhitelist.isEmpty
                          ? _buildNoSearchResults(context)
                          : _view == _WhitelistView.list
                              ? _buildWhitelistContent(
                                  context, provider, filteredWhitelist)
                              : _buildWhitelistGrid(
                                  context, provider, filteredWhitelist),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sortWhitelist(List<String> whitelist, SortOption sort) {
    switch (sort) {
      case SortOption.dateDesc:
        final recentFirst = whitelist.reversed.toList();
        whitelist
          ..clear()
          ..addAll(recentFirst);
        break;
      case SortOption.dateAsc:
        break;
      case SortOption.alphaAsc:
        whitelist.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        break;
      case SortOption.alphaDesc:
        whitelist.sort((a, b) => b.toLowerCase().compareTo(a.toLowerCase()));
        break;
    }
  }

  Widget _buildViewSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          _buildViewOption(
            context,
            view: _WhitelistView.list,
            label: 'Lista',
            icon: Icons.menu,
          ),
          _buildViewOption(
            context,
            view: _WhitelistView.grid,
            label: 'Griglia',
            icon: Icons.grid_view_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildViewOption(
    BuildContext context, {
    required _WhitelistView view,
    required String label,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = _view == view;

    return Expanded(
      child: Material(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => setState(() => _view = view),
          child: SizedBox(
            height: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortSelector(BuildContext context, AppProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(28),
      ),
      child: PopupMenuButton<SortOption>(
        onSelected: provider.setSortOption,
        position: PopupMenuPosition.under,
        offset: const Offset(0, 4),
        color: colorScheme.surfaceContainerHighest,
        elevation: 8,
        constraints: const BoxConstraints(minWidth: 220, maxWidth: 240),
        menuPadding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colorScheme.outline, width: 1.5),
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
            SortOption.dateDesc || SortOption.alphaAsc => Icons.arrow_downward,
            SortOption.dateAsc || SortOption.alphaDesc => Icons.arrow_upward,
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
                        option == SortOption.alphaAsc ? 'A\nZ' : 'Z\nA',
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
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                                    color: colorScheme.onSurfaceVariant,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton(BuildContext context, AppProvider provider) {
    final errorColor = Theme.of(context).colorScheme.error;
    return Container(
      key: const Key('clear-whitelist-button-frame'),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: errorColor, width: 1.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: IconButton(
        onPressed: () => _showClearDialog(context, provider),
        icon: const Icon(Icons.delete_forever_outlined),
        tooltip: 'Svuota whitelist',
        color: errorColor,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cerca un profilo',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: const Icon(Icons.close),
                  tooltip: 'Cancella ricerca',
                ),
          filled: true,
          fillColor:
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildNoSearchResults(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Nessun profilo trovato',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 60,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Whitelist vuota',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Aggiungi profili alla whitelist per escluderli\n'
              'dall\'elenco dei non-follower.\n\n'
              'Puoi aggiungere profili dalla schermata\n'
              'principale toccando l\'icona del cuore\n'
              'sulla card di un profilo.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhitelistContent(
      BuildContext context, AppProvider provider, List<String> whitelist) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: whitelist.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final username = whitelist[index];
        return _buildWhitelistItem(context, provider, username);
      },
    );
  }

  Widget _buildWhitelistGrid(
    BuildContext context,
    AppProvider provider,
    List<String> whitelist,
  ) {
    final crossAxisCount =
        (MediaQuery.sizeOf(context).width / 180).floor().clamp(2, 4);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: whitelist.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final username = whitelist[index];
        final colorScheme = Theme.of(context).colorScheme;

        return Card(
          margin: EdgeInsets.zero,
          color: Theme.of(context).cardTheme.color,
          elevation: 3,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 4),
                _buildWhitelistAvatar(username, radius: 28),
                Text(
                  '@$username',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFramedActionButton(
                      context,
                      icon: Icons.open_in_new_rounded,
                      color: colorScheme.primary,
                      tooltip: 'Apri profilo',
                      onPressed: () => _openInstagramProfile(username),
                    ),
                    const SizedBox(width: 8),
                    _buildFramedActionButton(
                      context,
                      icon: Icons.delete_outline,
                      color: colorScheme.onSurfaceVariant,
                      tooltip: 'Rimuovi dalla whitelist',
                      onPressed: () async {
                        final confirmed =
                            await _showRemoveDialog(context, username);
                        if (confirmed == true) {
                          provider.removeFromWhitelist(username);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWhitelistItem(
      BuildContext context, AppProvider provider, String username) {
    final swipeGradient =
        statsCounterGradientColors(context, provider.whitelist.length);
    return Dismissible(
      key: Key(username),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: swipeGradient,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: swipeGradient.last),
          boxShadow: [
            BoxShadow(
              color: swipeGradient.last.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              'Rimuovi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showRemoveDialog(context, username);
      },
      onDismissed: (direction) {
        provider.removeFromWhitelist(username);
      },
      child: Card(
        elevation: 0,
        color: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _buildWhitelistAvatar(username, radius: 24),
          title: Text(
            username,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            'Escluso dal report',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFramedActionButton(
                context,
                icon: Icons.open_in_new,
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => _openInstagramProfile(username),
                tooltip: 'Apri profilo Instagram',
              ),
              const SizedBox(width: 8),
              _buildFramedActionButton(
                context,
                icon: Icons.delete_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                onPressed: () async {
                  final confirmed = await _showRemoveDialog(context, username);
                  if (confirmed == true) {
                    provider.removeFromWhitelist(username);
                  }
                },
                tooltip: 'Rimuovi dalla whitelist',
              ),
            ],
          ),
          onTap: () => _openInstagramProfile(username),
        ),
      ),
    );
  }

  Future<bool?> _showRemoveDialog(BuildContext context, String username) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.remove_circle_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            const Text('Rimuovi dalla whitelist'),
          ],
        ),
        content: Text(
          'Vuoi rimuovere "$username" dalla whitelist?\n'
          'Tornerà a comparire nell\'elenco dei non-follower.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Rimuovi'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearDialog(
      BuildContext context, AppProvider provider) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
        contentTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
        title: Row(
          children: [
            Icon(
              Icons.delete_forever_outlined,
              color: colorScheme.error,
            ),
            const SizedBox(width: 12),
            const Text('Svuota whitelist'),
          ],
        ),
        content: const Text(
          'Sei sicuro di voler rimuovere tutti i profili dalla whitelist? '
          'Questa azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
            ),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Svuota tutto'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      provider.clearWhitelist();
    }
  }

  Future<void> _openInstagramProfile(String username) async {
    final url = Uri.parse('https://instagram.com/$username');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
