import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/api_client.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  final Future<void> Function(String identifier, String password) onSignIn;
  final VoidCallback onSuccess;
  const LoginScreen({super.key, required this.onSignIn, required this.onSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _identifierFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _pending = false;
  bool _visible = false;
  String? _identifierError;
  String? _passwordError;
  String? _formError;

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
    setState(() {
      _identifierError = _identifier.text.trim().isEmpty ? 'Enter an email or mobile number.' : null;
      _passwordError = _password.text.isEmpty ? 'Enter your password.' : null;
      _formError = null;
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
      await widget.onSignIn(_identifier.text.trim(), _password.text);
      if (mounted) widget.onSuccess();
    } catch (e) {
      if (mounted) {
        setState(() {
          _formError = e is ApiException && e.statusCode == null
              ? 'Cannot reach the server. Please try again.'
              : 'Sign in could not be completed. Check your credentials and try again.';
          _password.clear();
        });
      }
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Sign in', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  key: const Key('login-identifier'),
                  controller: _identifier,
                  focusNode: _identifierFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  decoration: InputDecoration(
                    labelText: 'Email or mobile number',
                    border: const OutlineInputBorder(),
                    errorText: _identifierError,
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
                    border: const OutlineInputBorder(),
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      tooltip: _visible ? 'Hide password' : 'Show password',
                      onPressed: () => setState(() => _visible = !_visible),
                      icon: Icon(_visible ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                ),
                if (_formError != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    liveRegion: true,
                    child: Text(_formError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  key: const Key('login-submit'),
                  label: 'Sign in',
                  loading: _pending,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
