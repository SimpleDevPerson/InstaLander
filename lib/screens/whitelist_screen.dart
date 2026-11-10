import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class WhitelistScreen extends StatelessWidget {
  const WhitelistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final whitelist = provider.whitelist.toList();

        return Scaffold(
          backgroundColor: AppTheme.getBgColor(context),
          appBar: AppBar(
            backgroundColor: AppTheme.getCardBg(context),
            foregroundColor: AppTheme.getTextColor(context),
            elevation: 0,
            surfaceTintColor: AppTheme.getCardBg(context),
            centerTitle: false,
            titleSpacing: 16,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Whitelist',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            actions: [
              if (whitelist.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _showClearDialog(context, provider),
                  icon: const Icon(Icons.delete_forever_outlined, size: 18),
                  label: const Text('Svuota tutto'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              const SizedBox(width: 16),
            ],
          ),
          body: whitelist.isEmpty
              ? _buildEmptyState(context)
              : _buildWhitelistContent(context, provider, whitelist),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
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

  Widget _buildWhitelistContent(BuildContext context, AppProvider provider, List<String> whitelist) {
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

  Widget _buildWhitelistItem(BuildContext context, AppProvider provider, String username) {
    return Dismissible(
      key: Key(username),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
          size: 28,
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
              IconButton(
                icon: Icon(
                  Icons.open_in_new,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => _openInstagramProfile(username),
                tooltip: 'Apri profilo Instagram',
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () => _showRemoveDialog(context, username).then((confirmed) {
                  if (confirmed == true) {
                    provider.removeFromWhitelist(username);
                  }
                }),
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
            ),
            child: const Text('Rimuovi'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearDialog(BuildContext context, AppProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.delete_forever_outlined,
              color: Theme.of(context).colorScheme.error,
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
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
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