import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class StudentBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onBookTap;

  const StudentBottomNav({super.key, required this.currentIndex, required this.onTap, required this.onBookTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  selected: currentIndex == 0,
                  outlineIcon: Icons.home_outlined,
                  filledIcon: Icons.home_rounded,
                  label: "Home",
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  selected: currentIndex == 1,
                  outlineIcon: Icons.calendar_today_outlined,
                  filledIcon: Icons.calendar_month_rounded,
                  label: "Sessions",
                  onTap: () => onTap(1),
                ),
                // Center Add Button
                GestureDetector(
                  onTap: onBookTap,
                  child: Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: const BoxDecoration(color: AppTheme.maroon, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
                _NavItem(
                  selected: currentIndex == 2,
                  outlineIcon: Icons.school_outlined,
                  filledIcon: Icons.school_rounded,
                  label: "Tutors",
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  selected: currentIndex == 3,
                  outlineIcon: Icons.person_outline_rounded,
                  filledIcon: Icons.person_rounded,
                  label: "Profile",
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final bool selected;
  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.selected, required this.outlineIcon, required this.filledIcon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppTheme.maroon;
    final Color inactiveColor = const Color(0xFFB0A8AA);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Icon(
                  selected ? filledIcon : outlineIcon,
                  key: ValueKey(selected),
                  color: selected ? activeColor : inactiveColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: selected ? activeColor : inactiveColor,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.1,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
