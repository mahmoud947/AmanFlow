import 'package:flutter/material.dart';
import '../widgets/app_bottom_navigation.dart';
import 'home_screen.dart';
import 'payments_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  final Future<void> Function() onLogout;
  const AppShell({super.key, required this.onLogout});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onOpenPayments: () => setState(() => _index = 1)),
      const PaymentsScreen(),
      ProfileScreen(onLogout: widget.onLogout),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppBottomNavigation(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}
