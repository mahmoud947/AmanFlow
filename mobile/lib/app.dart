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
  bool _signedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmanFlow',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: _signedIn
          ? ChangeNotifierProvider(
              create: (_) => AppState(widget.repository)..load(),
              child: const AppShell(),
            )
          : LoginScreen(
              onSignIn: widget.repository.signIn,
              onSuccess: () => setState(() => _signedIn = true),
            ),
    );
  }
}
