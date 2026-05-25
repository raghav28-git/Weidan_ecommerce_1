import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'otp_verification_screen.dart';
import '../../utils/responsive.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  static const _bg = Color(0xFF0B0B0B);
  static const _border = Color(0xFF2A2A2A);
  static const _textPrimary = Colors.white;
  static const _textMuted = Color(0xFF6B7280);

  _sendResetCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.resetPassword(_emailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset code sent to your email'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Scrollable content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.formPadding(context),
                      vertical: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                              fontFamily: 'SF Pro Display',
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Subtitle
                          Text(
                            'Enter the email linked to your account and we\'ll send you a reset code.',
                            style: TextStyle(
                              fontSize: 14,
                              color: _textMuted,
                              fontFamily: 'SF Pro Display',
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Email label
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _textPrimary,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Email input
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'SF Pro Display',
                            ),
                            decoration: InputDecoration(
                              hintText: 'hello@gmail.com',
                              hintStyle: const TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 15,
                                fontFamily: 'SF Pro Display',
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1A1A1A),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFF2A2A2A)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFF2A2A2A)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF3F3F3F), width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFEF4444)),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFEF4444), width: 1.5),
                              ),
                              errorStyle: const TextStyle(
                                  color: Color(0xFFEF4444)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Enter your email';
                              if (!value.contains('@'))
                                return 'Enter a valid email';
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Send Code button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _sendResetCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF5F5F5),
                                foregroundColor: Colors.black,
                                disabledBackgroundColor:
                                    const Color(0xFFF5F5F5).withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black54,
                                      ),
                                    )
                                  : const Text(
                                      'Send Code',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'SF Pro Display',
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
