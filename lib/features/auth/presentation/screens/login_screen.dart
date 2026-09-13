import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../shared/providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

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

    final bool success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted || !success) {
      return;
    }

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
            content: Text('Unknown account role.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool wideScreen = screenWidth >= 900;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (wideScreen)
              Expanded(
                flex: 5,
                child: _BrandPanel(),
              ),
            Expanded(
              flex: 5,
              child: _LoginForm(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                obscurePassword: _obscurePassword,
                isLoading: auth.isLoading,
                errorMessage: auth.error,
                showMobileLogo: !wideScreen,
                onTogglePassword: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                onLogin: _login,
                onRegister: _openRegister,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF063F22),
      child: Stack(
        children: [
          Positioned(
            right: -90,
            bottom: -100,
            child: Icon(
              Icons.eco,
              size: 420,
              color: Colors.white.withAlpha(15),
            ),
          ),
          Positioned(
            left: -100,
            top: -100,
            child: Icon(
              Icons.eco,
              size: 300,
              color: Colors.white.withAlpha(10),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const BrandLogo(
                      height: 110,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'From our farms\nto your table.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'A smarter agricultural marketplace connecting '
                    'farmers, consumers and global buyers when surplus '
                    'creates new opportunities.',
                    style: TextStyle(
                      color: Color(0xFFD8F0DD),
                      fontSize: 16,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _BrandFeature(
                    icon: Icons.agriculture_outlined,
                    title: 'For Farmers',
                    subtitle: 'List your harvest and reach more customers.',
                  ),
                  const SizedBox(height: 14),
                  _BrandFeature(
                    icon: Icons.shopping_basket_outlined,
                    title: 'For Consumers',
                    subtitle: 'Buy fresh agricultural products directly.',
                  ),
                  const SizedBox(height: 14),
                  _BrandFeature(
                    icon: Icons.public_outlined,
                    title: 'For Global Buyers',
                    subtitle: 'Access eligible surplus opportunities.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BrandFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFB7E86B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFFB9D5C0),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final String? errorMessage;
  final bool showMobileLogo;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.errorMessage,
    required this.showMobileLogo,
    required this.onTogglePassword,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 460,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showMobileLogo) ...[
                      const Center(
                        child: BrandLogo(
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    const Text(
                      'Welcome to AgriNova',
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF113A23),
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Sign in to continue to your agricultural marketplace.',
                      style: TextStyle(
                        color: Color(0xFF718075),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'you@example.com',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => onLogin(),
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'Enter your 8+ character password';
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          onPressed: onTogglePassword,
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFB3261E),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: isLoading ? null : onLogin,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: onRegister,
                      icon: const Icon(
                        Icons.person_add_alt_1_outlined,
                      ),
                      label: const Text(
                        'Create an Account',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Farmers • Consumers • International Buyers',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7B887F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
