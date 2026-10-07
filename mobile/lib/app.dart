import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'data/repository.dart';
import 'screens/login_screen.dart';
import 'screens/shell.dart';
import 'state/app_state.dart';

class AmanFlowApp extends StatefulWidget {
  final FinanceRepository repository;
  const AmanFlowApp({super.key, required this.repository});

  @override
  State<AmanFlowApp> createState() => _AmanFlowAppState();
}

class _AmanFlowAppState extends State<AmanFlowApp> {
  late final AppState _state = AppState(widget.repository);
  bool _authenticated = false;

  Future<void> _signIn(String identifier, String password) async {
    await widget.repository.signIn(identifier, password);
    if (!mounted) return;
    setState(() => _authenticated = true);
    await _state.load();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _state,
      child: MaterialApp(
        title: 'AmanFlow',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: _authenticated
            ? const AppShell()
            : LoginScreen(onSignIn: _signIn),
      ),
    );
  }
}
