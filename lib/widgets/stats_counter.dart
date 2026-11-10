import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatsCounter extends StatelessWidget {
  final int count;

  const StatsCounter({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Da controllare: ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getSubTextColor(context),
            ),
          ),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: count),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: count > 0 ? AppTheme.instagramRed : AppTheme.getTextColor(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}