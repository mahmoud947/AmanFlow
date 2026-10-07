import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/api_client.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  final Future<void> Function(String identifier, String password) onSignIn;
  const LoginScreen({super.key, required this.onSignIn});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _identifierFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _visible = false;
  bool _pending = false;
  String? _identifierError;
  String? _passwordError;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    _identifierFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_pending) return;
    final identifier = _identifier.text.trim();
    final password = _password.text;
    setState(() {
      _identifierError = identifier.isEmpty ? 'Enter your email or mobile number.' : null;
      _passwordError = password.isEmpty ? 'Enter your password.' : null;
      _error = null;
    });
    if (_identifierError != null) {
      _identifierFocus.requestFocus();
      return;
    }
    if (_passwordError != null) {
      _passwordFocus.requestFocus();
      return;
    }
    setState(() => _pending = true);
    try {
      await widget.onSignIn(identifier, password);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException && e.statusCode == 401
            ? 'Could not sign in. Check your credentials and try again.'
            : 'Cannot connect right now. Please try again.';
        _password.clear();
      });
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Sign in', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              key: const Key('login-identifier'),
              controller: _identifier,
              focusNode: _identifierFocus,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.username],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email or mobile number',
                errorText: _identifierError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('login-password'),
              controller: _password,
              focusNode: _passwordFocus,
              obscureText: !_visible,
              enableSuggestions: false,
              autocorrect: false,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _passwordError,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: _visible ? 'Hide password' : 'Show password',
                  onPressed: () => setState(() => _visible = !_visible),
                  icon: Icon(_visible ? Icons.visibility_off : Icons.visibility),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Semantics(liveRegion: true, child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
            ],
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Sign in', loading: _pending, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
