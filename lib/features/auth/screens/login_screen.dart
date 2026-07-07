import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'BookinMan',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Enter a valid email',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v != null && v.length >= 6
                    ? null
                    : 'Minimum 6 characters',
              ),
              const SizedBox(height: 16),
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    auth.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              FilledButton(
                onPressed: auth.loading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await ref
                              .read(authControllerProvider.notifier)
                              .signIn(_email.text.trim(), _password.text);
                        }
                      },
                child: auth.loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in'),
              ),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text('Create an account'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: auth.loading
                    ? null
                    : () => ref
                        .read(authControllerProvider.notifier)
                        .signInWithGoogle(),
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Continue with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
