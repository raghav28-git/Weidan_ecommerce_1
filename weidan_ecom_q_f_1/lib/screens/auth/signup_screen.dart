import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../user/home_screen.dart';
import '../admin/admin_dashboard.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  _signUp() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }
      
      setState(() => _isLoading = true);
      
      try {
        UserModel? user = await _authService.signUp(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (user != null) {
          if (user.role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: ${e.toString()}')),
        );
      }
      
      setState(() => _isLoading = false);
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please agree to Terms of Services and Privacy Policy')),
      );
    }
  }

  _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      UserModel? user = await _authService.signInWithGoogle();
      if (user != null) {
        if (user.role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${e.toString()}')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final padding = screenWidth * 0.06;
            final titleSize = screenWidth * 0.08;
            final subtitleSize = screenWidth * 0.04;
            final inputHeight = screenWidth * 0.14;
            final buttonHeight = screenWidth * 0.14;
            final spacing = screenHeight * 0.025;
            
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: Padding(
                  padding: EdgeInsets.all(padding.clamp(20, 32)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: spacing.clamp(16, 32)),
                      
                      // Header / Greeting
                      Text(
                        'Hello there!',
                        style: TextStyle(
                          fontSize: titleSize.clamp(28, 36),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      
                      SizedBox(height: spacing.clamp(10, 16)),
                      
                      // Subtext
                      Text(
                        'Create an account to access your order history and get real-time shipment updates.',
                        style: TextStyle(
                          fontSize: subtitleSize.clamp(14, 18),
                          color: Colors.grey[600],
                          fontFamily: 'Montserrat',
                          height: 1.4,
                        ),
                      ),
                      
                      SizedBox(height: spacing.clamp(24, 40)),
                      
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email/Phone field
                            TextFormField(
                              controller: _emailController,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: subtitleSize.clamp(14, 18),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your mail/phone number',
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontFamily: 'Montserrat',
                                  fontSize: subtitleSize.clamp(14, 18),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.purple, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: padding.clamp(14, 20),
                                  vertical: (inputHeight * 0.25).clamp(14, 18),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Enter email or phone';
                                return null;
                              },
                            ),
                            
                            SizedBox(height: spacing.clamp(16, 24)),
                            
                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: subtitleSize.clamp(14, 18),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontFamily: 'Montserrat',
                                  fontSize: subtitleSize.clamp(14, 18),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.purple, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: padding.clamp(14, 20),
                                  vertical: (inputHeight * 0.25).clamp(14, 18),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey[600],
                                    size: (screenWidth * 0.055).clamp(20, 26),
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Enter password';
                                if (value.length < 6) return 'Password must be 6+ characters';
                                return null;
                              },
                            ),
                            
                            SizedBox(height: spacing.clamp(16, 24)),
                            
                            // Re-type Password field
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: subtitleSize.clamp(14, 18),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Re-type your password',
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontFamily: 'Montserrat',
                                  fontSize: subtitleSize.clamp(14, 18),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.purple, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: padding.clamp(14, 20),
                                  vertical: (inputHeight * 0.25).clamp(14, 18),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey[600],
                                    size: (screenWidth * 0.055).clamp(20, 26),
                                  ),
                                  onPressed: () {
                                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Re-enter password';
                                return null;
                              },
                            ),
                            
                            SizedBox(height: spacing.clamp(18, 28)),
                            
                            // Terms & Privacy Agreement
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.scale(
                                  scale: (screenWidth * 0.0025).clamp(0.9, 1.1),
                                  child: Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (value) {
                                      setState(() => _agreeToTerms = value ?? false);
                                    },
                                    activeColor: Colors.purple,
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _agreeToTerms = !_agreeToTerms);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(top: (screenWidth * 0.03).clamp(10, 14)),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: (subtitleSize * 0.9).clamp(12, 16),
                                            color: Colors.grey[700],
                                            fontFamily: 'Montserrat',
                                          ),
                                          children: [
                                            TextSpan(text: 'By signing up, you agree to our '),
                                            TextSpan(
                                              text: 'Terms of Services',
                                              style: TextStyle(
                                                color: Colors.purple,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                            TextSpan(text: ' and '),
                                            TextSpan(
                                              text: 'Privacy Policy',
                                              style: TextStyle(
                                                color: Colors.purple,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: spacing.clamp(24, 36)),
                            
                            // Sign Up button
                            GestureDetector(
                              onTap: _isLoading ? null : _signUp,
                              child: Container(
                                width: double.infinity,
                                height: buttonHeight.clamp(52, 60),
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontSize: (subtitleSize * 1.1).clamp(16, 20),
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat',
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: spacing.clamp(24, 36)),
                            
                            // Divider
                            Text(
                              'or',
                              style: TextStyle(
                                fontSize: subtitleSize.clamp(14, 18),
                                color: Colors.grey[600],
                                fontFamily: 'Montserrat',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: spacing.clamp(18, 28)),
                            
                            // Continue with Google
                            GestureDetector(
                              onTap: _isLoading ? null : _signInWithGoogle,
                              child: Container(
                                width: double.infinity,
                                height: buttonHeight.clamp(52, 60),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.g_mobiledata,
                                      size: (screenWidth * 0.06).clamp(22, 28),
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        fontSize: subtitleSize.clamp(14, 18),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Montserrat',
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: spacing.clamp(24, 36)),
                            
                            // Already have account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    fontSize: (subtitleSize * 0.9).clamp(12, 16),
                                    color: Colors.grey[600],
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: (subtitleSize * 0.9).clamp(12, 16),
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}