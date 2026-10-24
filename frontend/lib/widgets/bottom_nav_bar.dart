import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/chat');
        break;
      case 2:
        context.go('/history');
        break;
      case 3:
        context.go('/favorites');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;
    final inactive = isDark ? AppColors.darkTextHint : AppColors.lightTextHint;
    final barColor = (isDark ? const Color(0xFF1C1C1E) : Colors.white).withValues(alpha: 0.82);
    final separator = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    const items = <_NavItem>[
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Ana Sayfa'),
      _NavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Sohbet'),
      _NavItem(icon: Icons.history_outlined, activeIcon: Icons.history, label: 'Geçmiş'),
      _NavItem(icon: Icons.favorite_border, activeIcon: Icons.favorite, label: 'Favoriler'),
      _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profil'),
    ];

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30, tileMode: TileMode.clamp),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: barColor,
            border: Border(top: BorderSide(color: separator, width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: currentIndex == i,
                        label: items[i].label,
                        child: InkWell(
                          onTap: () => _onTap(context, i),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                currentIndex == i ? items[i].activeIcon : items[i].icon,
                                size: 26,
                                color: currentIndex == i ? accent : inactive,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                items[i].label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: currentIndex == i ? FontWeight.w600 : FontWeight.w500,
                                  color: currentIndex == i ? accent : inactive,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
