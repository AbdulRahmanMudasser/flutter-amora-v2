import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amora/core/theme/theme.dart';
import 'package:amora/features/authentication/domain/auth_provider.dart';
import 'package:amora/features/authentication/presentation/widgets/custom_text_field.dart';
import 'package:email_validator/email_validator.dart';
import 'package:amora/features/authentication/presentation/screens/home_screen.dart';
import 'package:amora/features/authentication/presentation/screens/registration_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secretWordController = TextEditingController();
  String? _selectedRole;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _secretWordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog() {
    final _securityAnswerController = TextEditingController();
    String? _securityQuestion;

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85;

        return AlertDialog(
          backgroundColor: AppTheme.creamWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Recover Password',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18 * fontScaleFactor,
              color: AppTheme.deepRose,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
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
                const SizedBox(height: 16),
                FutureBuilder<String?>(
                  future: ref.read(authStateProvider.notifier).getSecurityQuestion(_emailController.text),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(color: AppTheme.roseGold);
                    }
                    _securityQuestion = snapshot.data;
                    return Text(
                      _securityQuestion ?? 'No user found for this email',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14 * fontScaleFactor,
                        color: _securityQuestion != null ? AppTheme.deepRose : Colors.redAccent,
                      ),
                    );
                  },
                ),
                if (_securityQuestion != null) ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Security Answer',
                    controller: _securityAnswerController,
                    prefixIcon: Icon(Icons.question_answer, color: AppTheme.roseGold, size: 20 * fontScaleFactor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an answer';
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.roseGold),
              ),
            ),
            if (_securityQuestion != null)
              ElevatedButton(
                onPressed: () async {
                  if (_securityAnswerController.text.isNotEmpty) {
                    final password = await ref.read(authStateProvider.notifier).recoverPassword(
                      _emailController.text,
                      _securityAnswerController.text,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          password != null ? 'Password: $password (for testing)' : 'Invalid answer',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.roseGold,
                  foregroundColor: AppTheme.creamWhite,
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
              ),
          ],
        );
      },
    );
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
                        'Welcome Back, Love',
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
                          'assets/images/login.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Error loading image: $error');
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
                      'Sign In to Your Story',
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
                          SizedBox(height: verticalSpacing),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordDialog,
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14 * fontScaleFactor,
                                  color: AppTheme.roseGold,
                                ),
                              ),
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
                                  final isAuthenticated = await ref.read(authStateProvider.notifier).login(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    secretWord: _secretWordController.text,
                                    role: _selectedRole!,
                                  );
                                  if (isAuthenticated) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Invalid credentials')),
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
                                    authState.isLoading ? 'Logging in...' : 'Login',
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
                                  'Don\'t have an account?',
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
                                      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Sign Up',
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