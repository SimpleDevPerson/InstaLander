import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SetupPanel extends StatelessWidget {
  const SetupPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getCardBg(context),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Configura il report',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Per iniziare, aggiungi i file JSON di Instagram con i tuoi follower e i profili che segui.\n\n'
            'Puoi scaricarli da Instagram:\n'
            'Impostazioni → Privacy e sicurezza → Scarica i dati',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.getSubTextColor(context),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Info chips
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                icon: Icons.people_outline,
                label: 'followers_*.json',
                color: Colors.blue,
              ),
              _InfoChip(
                icon: Icons.person_add_outlined,
                label: 'following_*.json',
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}