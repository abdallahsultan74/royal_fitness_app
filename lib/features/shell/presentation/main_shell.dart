import 'package:flutter/material.dart';

import '../../challenges/presentation/pages/challenges_page.dart';
import '../../home/presentation/pages/home_page.dart';
import '../../profile/presentation/pages/settings_page.dart';
import '../../progress/presentation/pages/progress_page.dart';
import '../../workout/presentation/pages/workout_library_page.dart';
import 'widgets/royal_bottom_nav.dart';

/// Lets descendants switch the bottom tab (e.g. Home → Workouts).
class MainShellScope extends InheritedWidget {
  const MainShellScope({
    super.key,
    required this.selectTab,
    required super.child,
  });

  final ValueChanged<int> selectTab;

  static void goToTab(BuildContext context, int index) {
    final scope = context.dependOnInheritedWidgetOfExactType<MainShellScope>();
    scope?.selectTab(index);
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) => false;
}

/// Main app area with bottom tabs (Figma `Layout` + `BottomNav`).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<Widget> _pages = [
    HomePage(),
    WorkoutLibraryPage(),
    ChallengesPage(),
    ProgressPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: MainShellScope(
        selectTab: (i) => setState(() => _index = i.clamp(0, _pages.length - 1)),
        child: IndexedStack(
          index: _index,
          children: _pages,
        ),
      ),
      bottomNavigationBar: RoyalBottomNav(
        currentIndex: _index,
        onSelect: (i) => setState(() => _index = i),
      ),
    );
  }
}
