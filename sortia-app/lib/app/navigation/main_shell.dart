// ================================================================
// SORTIA — Shell Navigation Principal
// BottomNavigationBar + pages principales
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sortia/features/explorer/presentation/screens/explorer_screen.dart';
import 'package:sortia/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:sortia/features/scanner/presentation/screens/scanner_screen.dart';
import 'package:sortia/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:sortia/features/settings/presentation/screens/settings_screen.dart';
import 'package:sortia/features/alerts/presentation/providers/alert_providers.dart';

/// Shell de navigation principal avec BottomNavigationBar
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late int _currentIndex;

  // Les 5 pages principales
  final _pages = const <Widget>[
    ExplorerScreen(),
    DashboardScreen(),
    ScannerScreen(),
    AlertsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadAlertsCountProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF1B4F72).withValues(alpha: 0.1),
          height: 65,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon:
                  Icon(Icons.folder, color: Color(0xFF1B4F72)),
              label: 'Fichiers',
            ),
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon:
                  Icon(Icons.dashboard, color: Color(0xFF1B4F72)),
              label: 'Tableau',
            ),
            NavigationDestination(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B4F72), Color(0xFF2E86C1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.document_scanner_outlined,
                    color: Colors.white, size: 22),
              ),
              label: 'Scanner',
            ),
            NavigationDestination(
              icon: unreadCount.when(
                data: (count) => count > 0
                    ? Badge(
                        label: Text('$count'),
                        child: const Icon(Icons.notifications_outlined),
                      )
                    : const Icon(Icons.notifications_outlined),
                loading: () => const Icon(Icons.notifications_outlined),
                error: (_, __) => const Icon(Icons.notifications_outlined),
              ),
              selectedIcon:
                  const Icon(Icons.notifications, color: Color(0xFF1B4F72)),
              label: 'Alertes',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon:
                  Icon(Icons.person, color: Color(0xFF1B4F72)),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
