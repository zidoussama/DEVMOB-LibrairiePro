import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../Config/routes.dart';
import '../../../providers/auth_provider.dart';

class VerificationWaitingScreen extends StatefulWidget {
  const VerificationWaitingScreen({super.key});

  @override
  State<VerificationWaitingScreen> createState() =>
      _VerificationWaitingScreenState();
}

class _VerificationWaitingScreenState extends State<VerificationWaitingScreen> {
  bool _checking = false;
  Timer? _verificationTimer;
  bool _sentInitialVerification = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendInitialVerificationEmail();
    });
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkVerificationStatus(showNotVerifiedMessage: false);
    });
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerificationStatus({
    bool showNotVerifiedMessage = true,
  }) async {
    if (_checking) return;

    setState(() {
      _checking = true;
    });

    final authProvider = context.read<AuthProvider>();
    final isVerified = await authProvider.refreshAndCheckEmailVerified();

    if (!mounted) return;

    setState(() {
      _checking = false;
    });

    if (isVerified) {
      _verificationTimer?.cancel();
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.main,
        (_) => false,
      );
      return;
    }

    if (showNotVerifiedMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre email n\'est pas encore verifie.'),
        ),
      );
    }
  }

  Future<void> _resendEmail() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resendEmailVerification();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Email de verification renvoye.'
              : (authProvider.errorMessage ?? 'Impossible de renvoyer l\'email.'),
        ),
      ),
    );
  }

  Future<void> _sendInitialVerificationEmail() async {
    if (_sentInitialVerification || !mounted) return;
    _sentInitialVerification = true;

    final authProvider = context.read<AuthProvider>();
    final isVerified = await authProvider.refreshAndCheckEmailVerified();
    if (!mounted || isVerified) return;

    await _resendEmail();
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification email'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.mark_email_unread_outlined,
              size: 72,
              color: Color(0xFF6D4C41),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verifiez votre email',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nous avons envoye un email de verification. '
              'Confirmez votre adresse puis appuyez sur "J\'ai verifie".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: (isLoading || _checking) ? null : _checkVerificationStatus,
                child: (_checking || isLoading)
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('J\'ai verifie'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: isLoading ? null : _resendEmail,
                child: const Text('Renvoyer l\'email'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: isLoading ? null : _logout,
              child: const Text('Se deconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}
