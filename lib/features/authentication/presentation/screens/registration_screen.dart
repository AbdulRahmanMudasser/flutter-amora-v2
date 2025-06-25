import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amora/core/theme/theme.dart';
import 'package:amora/features/authentication/domain/auth_provider.dart';
import 'package:amora/features/authentication/presentation/widgets/custom_text_field.dart';
import 'package:email_validator/email_validator.dart';
import 'package:amora/features/authentication/presentation/screens/otp_verification_screen.dart';

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
  final _confirmPasswordController = TextEditingController();
  final _securityAnswerController = TextEditingController();
  final _secretWordController = TextEditingController();
  String? _selectedRole;
  String? _selectedQuestion;

  final List<String> _securityQuestions = [
    'Place we first met?',
    'First gift we gave each other?',
    'Favorite song?',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _securityAnswerController.dispose();
    _secretWordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Dynamic sizing based on screen width
    final horizontalPadding = screenWidth * 0.02; // 2% for minimal margins
    final verticalSpacing = screenHeight * 0.015; // 1.5% of screen height
    final fieldWidthFraction = screenWidth > 600 ? 0.85 : 0.98; // 85% for tablets, 98% for mobiles
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85; // Font scaling

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
                    // AppBar-like header
                    Padding(
                      padding: EdgeInsets.only(top: verticalSpacing * 2, bottom: verticalSpacing),
                      child: Text(
                        'Our Love Story Begins',
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
                    // Romantic header image with decorative frame
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
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppTheme.softPink.withValues(alpha: 0.2),
                            child: Icon(
                              Icons.favorite,
                              size: screenWidth * 0.15,
                              color: AppTheme.roseGold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Decorative divider
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
                      'Create Your Romantic Profile',
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
                                if (value == null || value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: CustomTextField(
                              label: 'Confirm Password',
                              controller: _confirmPasswordController,
                              obscureText: true,
                              prefixIcon: Icon(Icons.lock, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
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
                                border: Theme.of(context).inputDecorationTheme.border,
                                enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                                focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                                filled: true,
                                fillColor: AppTheme.softPink.withValues(alpha: 0.2),
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
                          SizedBox(height: verticalSpacing),
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Security Question',
                                prefixIcon: Icon(Icons.question_mark, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                                border: Theme.of(context).inputDecorationTheme.border,
                                enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                                focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                                filled: true,
                                fillColor: AppTheme.softPink.withValues(alpha: 0.2),
                              ),
                              value: _selectedQuestion,
                              items: _securityQuestions.map((question) {
                                return DropdownMenuItem(
                                  value: question,
                                  child: Text(
                                    question,
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
                                  _selectedQuestion = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a security question';
                                }
                                return null;
                              },
                              isExpanded: true,
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: CustomTextField(
                              label: 'Security Answer',
                              controller: _securityAnswerController,
                              prefixIcon: Icon(Icons.text_fields, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an answer';
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
                              prefixIcon: Icon(Icons.password, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the special word';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: verticalSpacing * 2),
                          FractionallySizedBox(
                            widthFactor: fieldWidthFraction,
                            child: ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () async {
                                if (_formKey.currentState!.validate()) {
                                  if (_selectedRole != null && _selectedQuestion != null) {
                                    final userId = await ref.read(authStateProvider.notifier).register(
                                      username: _usernameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      role: _selectedRole!,
                                      securityQuestion: _selectedQuestion!,
                                      securityAnswer: _securityAnswerController.text,
                                      secretWord: _secretWordController.text,
                                    );
                                    if (userId != null) {
                                      final otp = await ref.read(authStateProvider.notifier).generateOtp(_emailController.text);
                                      if (otp.isNotEmpty) {
                                        // Show OTP for testing
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('OTP: $otp')),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => OtpVerificationScreen(email: _emailController.text, otp: otp),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Failed to generate OTP')),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Registration failed: Only two users allowed')),
                                      );
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.roseGold,
                                foregroundColor: AppTheme.creamWhite,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.1,
                                  vertical: screenHeight * 0.025,
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
                                  Icon(Icons.favorite, size: 18 * fontScaleFactor, color: AppTheme.creamWhite),
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