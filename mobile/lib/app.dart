import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'data/repository.dart';
import 'screens/shell.dart';
import 'state/app_state.dart';

class AmanFlowApp extends StatelessWidget {
  final FinanceRepository repository;
  const AmanFlowApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(repository)..load(),
      child: MaterialApp(
        title: 'AmanFlow',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const AppShell(),
      ),
    );
  }
}
