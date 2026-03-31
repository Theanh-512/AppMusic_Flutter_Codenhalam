import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.verifyOTP(
        widget.email,
        _otpController.text.trim(),
        OtpType.recovery,
      );
      
      if (!mounted) return;
      
      // OTP verified successfully, user is implicitly logged in contextually for recovery.
      // Now redirect to new password reset screen
      context.pushReplacement('/reset-password');
      
    } on AuthException catch (error) {
      if (!mounted) return;
      _showErrorDialog(error.message);
    } catch (error) {
      if (!mounted) return;
      _showErrorDialog('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendCode() async {
    setState(() => _isResending = true);
    
    try {
      final repository = ref.read(authRepositoryProvider);
      // Resend the reset email
      await repository.sendPasswordResetEmail(widget.email);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new confirmation code has been sent.'), backgroundColor: Colors.green),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      _showErrorDialog(error.message);
    } catch (error) {
      if (!mounted) return;
      _showErrorDialog('Could not resend code. Please try again later.');
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Verification Failed'),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(LucideIcons.key, size: 64, color: Colors.white),
                  const SizedBox(height: 32),
                  const Text(
                    'Check your email',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We sent a 6-digit confirmation code to\n${widget.email}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(height: 48),
                  
                  // OTP Input
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: (_) => _handleVerify(),
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(color: Colors.white, fontSize: 32, letterSpacing: 16.0, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      hintText: '000000',
                      hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 16.0),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Code is required';
                      if (val.length != 6) return 'Enter the full 6-digit code';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Verify Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.white38,
                      disabledForegroundColor: Colors.black54,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading 
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : const Text('Verify Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                  
                  // Resend Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Didn't receive it?", style: TextStyle(color: Colors.white70)),
                      TextButton(
                        onPressed: (_isLoading || _isResending) ? null : _handleResendCode,
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        child: _isResending 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Resend Code', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
