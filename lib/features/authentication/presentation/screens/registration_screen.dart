import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amora/core/theme/theme.dart';
import 'package:amora/features/authentication/domain/auth_provider.dart';
import 'package:amora/features/authentication/presentation/widgets/custom_text_field.dart';
import 'package:email_validator/email_validator.dart';
import 'package:amora/features/authentication/presentation/screens/otp_verification_screen.dart';
import 'package:amora/features/authentication/presentation/screens/login_screen.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _securityQuestionController = TextEditingController();
  final _securityAnswerController = TextEditingController();
  final _secretWordController = TextEditingController();
  String? _selectedRole;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _securityQuestionController.dispose();
    _securityAnswerController.dispose();
    _secretWordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.02;
    final verticalSpacing = screenHeight * 0.015;
    final fieldWidthFraction = screenWidth > 600 ? 0.85 : 0.98;
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85;

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.creamWhite,
              AppTheme.softPink.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalSpacing * 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: verticalSpacing * 2, bottom: verticalSpacing),
                      child: Text(
                        'Begin Your Love Story',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22 * fontScaleFactor,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepRose,
                          shadows: [
                            Shadow(
                              blurRadius: 3,
                              color: AppTheme.roseGold.withValues(alpha: 0.3),
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: verticalSpacing * 2),
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.18,
                        maxWidth: screenWidth * 0.85,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.roseGold, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.softPink.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/register.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            return Container(
                              color: AppTheme.softPink.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.favorite,
                                size: screenWidth * 0.15,
                                color: AppTheme.roseGold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, size: 20, color: AppTheme.roseGold),
                        SizedBox(width: 8),
                        Expanded(
                          child: Divider(color: AppTheme.roseGold, thickness: 1),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.favorite, size: 20, color: AppTheme.roseGold),
                      ],
                    ),
                    SizedBox(height: verticalSpacing * 2),
                    Text(
                      'Create Your Account',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 26 * fontScaleFactor,
                        color: AppTheme.deepRose,
                        shadows: [
                          Shadow(
                            blurRadius: 3,
                            color: AppTheme.roseGold.withValues(alpha: 0.3),
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: verticalSpacing * 2),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: CustomTextField(
                              label: 'Username',
                              controller: _usernameController,
                              prefixIcon: Icon(Icons.person, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a username';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: CustomTextField(
                              label: 'Email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icon(Icons.email, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                              validator: (value) {
                                if (value == null || !EmailValidator.validate(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: CustomTextField(
                              label: 'Password',
                              controller: _passwordController,
                              obscureText: true,
                              prefixIcon: Icon(Icons.lock, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: CustomTextField(
                              label: 'Security Question',
                              controller: _securityQuestionController,
                              prefixIcon: Icon(Icons.question_mark, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a security question';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: CustomTextField(
                              label: 'Security Answer',
                              controller: _securityAnswerController,
                              prefixIcon: Icon(Icons.question_answer, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a security answer';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: CustomTextField(
                              label: 'Our Special Word',
                              controller: _secretWordController,
                              prefixIcon: Icon(Icons.favorite, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the special word';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Role',
                                prefixIcon: Icon(Icons.favorite_border, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                                filled: true,
                                fillColor: AppTheme.softPink.withValues(alpha: 0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.deepRose, width: 2),
                                ),
                              ),
                              value: _selectedRole,
                              items: ['Husband', 'Wife'].map((role) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(
                                    role,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14 * fontScaleFactor,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a role';
                                }
                                return null;
                              },
                              isExpanded: true,
                            ),
                          ),
                          SizedBox(height: verticalSpacing * 2),
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () async {
                                if (_formKey.currentState!.validate() && _selectedRole != null) {
                                  final userId = await ref.read(authStateProvider.notifier).register(
                                    username: _usernameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    role: _selectedRole!,
                                    securityQuestion: _securityQuestionController.text,
                                    securityAnswer: _securityAnswerController.text,
                                    secretWord: _secretWordController.text,
                                  );
                                  if (userId != null) {
                                    final otp = await ref.read(authStateProvider.notifier).generateOtp(_emailController.text);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('OTP: $otp (for testing)')),
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OtpVerificationScreen(
                                          email: _emailController.text,
                                          otp: otp,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(authState.error ?? 'Registration failed')),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.roseGold,
                                foregroundColor: AppTheme.creamWhite,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.1,
                                  vertical: screenHeight * 0.02,
                                ),
                                minimumSize: Size(double.infinity, screenHeight * 0.05),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: AppTheme.deepRose, width: 1.5),
                                ),
                                elevation: 4,
                                shadowColor: AppTheme.softPink.withValues(alpha: 0.4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 18 * fontScaleFactor,
                                    color: AppTheme.creamWhite,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    authState.isLoading ? 'Registering...' : 'Register',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16 * fontScaleFactor,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.creamWhite,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16 * fontScaleFactor,
                                    color: AppTheme.deepRose,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16 * fontScaleFactor,
                                      color: AppTheme.roseGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}