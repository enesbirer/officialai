import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _onTap(int index) {
    switch (index) {
      case 0: context.go('/dashboard'); break;
      case 1: context.go('/chat'); break;
      case 2: context.go('/history'); break;
      case 3: context.go('/favorites'); break;
      case 4: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        borderRadius: 26,
        blurX: 22,
        blurY: 22,
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: widget.currentIndex,
            onDestinationSelected: _onTap,
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            height: 62,
            indicatorColor: AppColors.icePrimary.withAlpha(55),
            indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, size: 26),
                selectedIcon: Icon(Icons.home, size: 26, color: Colors.white),
                label: 'Ana Sayfa',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded, size: 26),
                selectedIcon: Icon(Icons.chat_bubble, size: 26, color: Colors.white),
                label: 'Sohbet',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined, size: 26),
                selectedIcon: Icon(Icons.history, size: 26, color: Colors.white),
                label: 'Geçmiş',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_border, size: 26),
                selectedIcon: Icon(Icons.favorite, size: 26, color: Colors.white),
                label: 'Favoriler',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, size: 26),
                selectedIcon: Icon(Icons.person, size: 26, color: Colors.white),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
