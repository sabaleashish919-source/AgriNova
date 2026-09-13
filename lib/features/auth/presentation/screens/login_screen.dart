import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      final user = ref.read(authProvider).user;

      if (user == null) {
        return;
      }

      switch (user.role) {
        case 'FARMER':
          context.go('/farmer');
          break;

        case 'CONSUMER':
          context.go('/consumer');
          break;

        case 'INTERNATIONAL_BUYER':
          context.go('/international');
          break;

        case 'ADMIN':
          context.go('/admin');
          break;

        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Unknown account role.',
              ),
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.agriculture,
                          size: 70,
                          color: Color(
                            0xFF176B2C,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Text(
                          'AgroSurplus',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text(
                          'Smart Agricultural Marketplace',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: Validators.password,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(
                              Icons.lock,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (auth.error != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 16,
                            ),
                            child: Text(
                              auth.error!,
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: auth.isLoading ? null : _login,
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                  ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Create Account')),
                        const SizedBox(height: 4),
                        const Text(
                          'Create a Farmer, Consumer or International Buyer account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
