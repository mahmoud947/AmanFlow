import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'data/api_client.dart';
import 'data/biometric_authenticator.dart';
import 'data/repository.dart';
import 'data/session_store.dart';
import 'screens/login_screen.dart';
import 'screens/shell.dart';
import 'state/app_state.dart';

enum _Gate { checking, login, unlock, prompting, validating, authenticated, clearing, clearFailed }

class AmanFlowApp extends StatefulWidget {
  final FinanceRepository repository;
  final SessionStore? sessionStore;
  final BiometricAuthenticator? biometrics;
  const AmanFlowApp({super.key, required this.repository, this.sessionStore, this.biometrics});

  @override
  State<AmanFlowApp> createState() => _AmanFlowAppState();
}

class _AmanFlowAppState extends State<AmanFlowApp> with WidgetsBindingObserver {
  late final SessionStore _store = widget.sessionStore ?? PlatformSessionStore();
  late final BiometricAuthenticator _biometrics = widget.biometrics ?? PlatformBiometricAuthenticator();
  _Gate _gate = _Gate.checking;
  String? _session;
  String? _message;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkEligibility();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A resumed, already-authorized app must conceal its data before checking
    // the stored session again. Do not relaunch a prompt when its OS UI resumes.
    if (state == AppLifecycleState.resumed && _gate == _Gate.authenticated) {
      widget.repository.clearSession();
      _checkEligibility();
    }
  }

  @override
  void dispose() {
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showLogin([String? message]) {
    widget.repository.clearSession();
    _session = null;
    setState(() {
      _message = message;
      _gate = _Gate.login;
    });
  }

  Future<void> _checkEligibility() async {
    final generation = ++_generation;
    setState(() {
      _gate = _Gate.checking;
      _message = null;
      _session = null;
    });
    try {
      final session = await _store.read();
      if (!mounted || generation != _generation) return;
      if (session == null || session.isEmpty) {
        _showLogin();
        return;
      }
      if (!await _biometrics.isAvailable()) {
        if (mounted && generation == _generation) _showLogin();
        return;
      }
      if (!mounted || generation != _generation) return;
      setState(() {
        _session = session;
        _gate = _Gate.unlock;
      });
    } catch (_) {
      if (mounted && generation == _generation) _showLogin();
    }
  }

  Future<void> _signIn(String identifier, String password) async {
    final generation = _generation;
    await widget.repository.signIn(identifier, password);
    final session = widget.repository.sessionMaterial;
    if (session == null || session.isEmpty || !mounted || generation != _generation) {
      widget.repository.clearSession();
      throw StateError('No active session.');
    }
    try {
      await _store.write(session);
    } catch (_) {
      widget.repository.clearSession();
      rethrow;
    }
    if (!mounted || generation != _generation) {
      widget.repository.clearSession();
      throw StateError('Sign in interrupted.');
    }
  }

  void _signedIn() {
    if (mounted && _gate == _Gate.login && widget.repository.sessionMaterial != null) {
      setState(() {
        _message = null;
        _gate = _Gate.authenticated;
      });
    }
  }

  Future<void> _unlock() async {
    if (_gate != _Gate.unlock || _session == null) return;
    final generation = _generation;
    final session = _session!;
    setState(() => _gate = _Gate.prompting);
    try {
      final success = await _biometrics.authenticate();
      if (!mounted || generation != _generation) return;
      if (!success) {
        _showLogin('Sign in with your password to continue.');
        return;
      }
      setState(() => _gate = _Gate.validating);
      try {
        await widget.repository.validateSession(session);
        if (mounted && generation == _generation && _gate == _Gate.validating) {
          setState(() {
            _session = null;
            _gate = _Gate.authenticated;
          });
        }
      } on ApiException catch (e) {
        widget.repository.clearSession();
        if (!mounted || generation != _generation) return;
        if (e.statusCode == 401) {
          // Only a confirmed unauthorized response invalidates stored material.
          await _clearInvalid(generation);
        } else {
          _showLogin('Your session could not be confirmed. Sign in with your password.');
        }
      } catch (_) {
        widget.repository.clearSession();
        if (mounted && generation == _generation) {
          _showLogin('Your session could not be confirmed. Sign in with your password.');
        }
      }
    } catch (_) {
      if (mounted && generation == _generation) {
        _showLogin('Sign in with your password to continue.');
      }
    }
  }

  Future<void> _clearInvalid(int generation) async {
    setState(() => _gate = _Gate.clearing);
    try {
      await _store.clear();
      if (mounted && generation == _generation) {
        _showLogin('Your session expired. Sign in with your password.');
      }
    } catch (_) {
      if (mounted && generation == _generation) setState(() => _gate = _Gate.clearFailed);
    }
  }

  Future<void> _logout() async {
    ++_generation; // Invalidate pending unlock, validation, or storage reads.
    widget.repository.clearSession();
    setState(() {
      _session = null;
      _gate = _Gate.clearing;
    });
    try {
      await _store.clear();
      if (mounted) _showLogin();
    } catch (_) {
      if (mounted) setState(() => _gate = _Gate.clearFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_gate) {
      case _Gate.authenticated:
        content = ChangeNotifierProvider(
          create: (_) => AppState(widget.repository)..load(),
          child: AppShell(onLogout: _logout),
        );
      case _Gate.login:
        content = Column(
          children: [
            if (_message != null) Semantics(
              liveRegion: true,
              child: Material(child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(_message!),
              )),
            ),
            Expanded(child: LoginScreen(onSignIn: _signIn, onSuccess: _signedIn)),
          ],
        );
      default:
        content = Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    Text('Unlock your session', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.md),
                    Semantics(
                      liveRegion: _gate != _Gate.prompting,
                      child: Text(switch (_gate) {
                        _Gate.checking => 'Checking your session…',
                        _Gate.prompting => 'Use your device biometric prompt.',
                        _Gate.validating => 'Checking your session with the server…',
                        _Gate.clearing => 'Clearing your session…',
                        _Gate.clearFailed => 'Session could not be cleared. Retry to finish safely.',
                        _ => 'Continue with biometrics or use your password.',
                      }),
                    ),
                    if (_gate == _Gate.checking || _gate == _Gate.validating || _gate == _Gate.clearing)
                      const Center(child: CircularProgressIndicator()),
                    if (_gate == _Gate.unlock)
                      FilledButton(onPressed: _unlock, child: const Text('Unlock with biometrics')),
                    if (_gate == _Gate.clearFailed)
                      FilledButton(onPressed: _logout, child: const Text('Retry logout')),
                    if (_gate == _Gate.unlock || _gate == _Gate.prompting || _gate == _Gate.validating)
                      TextButton(
                        onPressed: () {
                          ++_generation;
                          _showLogin();
                        },
                        child: const Text('Use password'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
    }
    return MaterialApp(
      title: 'AmanFlow',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: content,
    );
  }
}
